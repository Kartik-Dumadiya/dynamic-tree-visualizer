import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/tree_node.dart';
import '../providers/tree_provider.dart';
import '../utils/constants.dart';
import '../widgets/application_examples.dart';
import 'package:provider/provider.dart';

class TreeVisualizer extends StatefulWidget {
  final bool isSmallScreen;
  final bool isMediumScreen;
  final bool isLargeScreen;

  const TreeVisualizer({
    Key? key,
    this.isSmallScreen = false,
    this.isMediumScreen = false,
    this.isLargeScreen = true,
  }) : super(key: key);

  @override
  State<TreeVisualizer> createState() => TreeVisualizerState();
}

class TreeVisualizerState extends State<TreeVisualizer>
    with TickerProviderStateMixin {
  TreeNode? _rootNode;
  double _currentScale = 1.0;

  late TransformationController _transformationController;
  late AnimationController _recenterAnimationController;
  late AnimationController _nodeAnimationController;
  late AnimationController _deleteAnimationController;
  
  // Animation tracking
  Map<String, AnimationController> _nodeAnimations = {};
  Set<String> _animatingNodes = {};
  String? _deletingNodeId;
  
  // Advanced animation states
  Map<String, double> _connectionProgress = {}; // For animated connector lines
  Map<String, double> _nodeAppearProgress = {}; // For node appearance after line
  Set<String> _deletingNodes = {};
  Map<String, double> _deleteProgress = {};
  Map<String, double> _deleteConnectionProgress = {}; // For reverse line animation
  Map<String, Offset> _originalPositions = {}; // Store positions before deletion
  
  // Subtree fade-out animation for nodes with children
  Set<String> _fadingSubtreeNodes = {}; // Nodes that are fading as part of subtree deletion
  Map<String, double> _subtreeFadeProgress = {}; // Fade progress for subtree nodes

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _recenterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _nodeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _deleteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _recenterTree();
        }
      });
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _recenterAnimationController.dispose();
    _nodeAnimationController.dispose();
    _deleteAnimationController.dispose();
    
    // Dispose individual node animation controllers
    for (var controller in _nodeAnimations.values) {
      controller.dispose();
    }
    _nodeAnimations.clear();
    
    super.dispose();
  }

  // Helper method to get current node scales for animation
  Map<String, double> _getNodeScales() {
    Map<String, double> scales = {};
    for (var nodeId in _animatingNodes) {
      // For deletion animation
      if (_deletingNodes.contains(nodeId)) {
        scales[nodeId] = 1.0 - (_deleteProgress[nodeId] ?? 0.0);
      } 
      // For addition animation - node appearance phase
      else if (_nodeAppearProgress.containsKey(nodeId)) {
        scales[nodeId] = _nodeAppearProgress[nodeId] ?? 0.0;
      }
      // For addition animation - line phase (node should be hidden until appearance starts)
      else if (_connectionProgress.containsKey(nodeId)) {
        scales[nodeId] = 0.0; // Node is hidden during line animation
      }
      else {
        scales[nodeId] = 1.0; // Default to visible
      }
    }
    return scales;
  }

  // Get connection animation progress
  Map<String, double> _getConnectionProgress() {
    return Map<String, double>.from(_connectionProgress);
  }

  // Modern professional node addition animation
  void _animateNewNode(String nodeId) {
    // Clean up any existing animation for this node
    if (_nodeAnimations.containsKey(nodeId)) {
      _nodeAnimations[nodeId]!.dispose();
    }
    
    // Phase 1: Animate connector line (800ms)
    final lineController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    final lineAnimation = CurvedAnimation(
      parent: lineController,
      curve: Curves.easeOutCubic,
    );
    
    lineAnimation.addListener(() {
      setState(() {
        _connectionProgress[nodeId] = lineAnimation.value;
      });
    });
    
    lineAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Phase 2: Animate node appearance (600ms) with modern scale + fade
        _animateNodeAppearance(nodeId);
      }
    });
    
    _nodeAnimations[nodeId] = lineController;
    _animatingNodes.add(nodeId);
    _connectionProgress[nodeId] = 0.0;
    
    // Start line animation
    lineController.forward();
  }

  // Phase 2: Node appearance with simple fade animation
  void _animateNodeAppearance(String nodeId) {
    final nodeController = AnimationController(
      duration: const Duration(milliseconds: 400), // Shorter for simple fade
      vsync: this,
    );
    
    final nodeAnimation = CurvedAnimation(
      parent: nodeController,
      curve: Curves.easeOut, // Simple smooth curve instead of elastic
    );
    
    nodeAnimation.addListener(() {
      setState(() {
        _nodeAppearProgress[nodeId] = nodeAnimation.value;
      });
    });
    
    nodeAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Cleanup animation state
        _animatingNodes.remove(nodeId);
        _connectionProgress.remove(nodeId);
        _nodeAppearProgress.remove(nodeId);
        _nodeAnimations[nodeId]?.dispose();
        _nodeAnimations.remove(nodeId);
      }
    });
    
    // Replace the controller
    _nodeAnimations[nodeId]?.dispose();
    _nodeAnimations[nodeId] = nodeController;
    _nodeAppearProgress[nodeId] = 0.0;
    
    nodeController.forward();
  }

  // Enhanced deletion animation with subtree fade-out
  void _animateDeleteNode(String nodeId, VoidCallback onComplete) {
    final treeProvider = Provider.of<TreeProvider>(context, listen: false);
    final nodeToDelete = _findNodeById(treeProvider.root, nodeId);
    
    if (nodeToDelete == null) {
      onComplete();
      return;
    }
    
    // Start subtree fade-out animation if node has children
    if (nodeToDelete.children.isNotEmpty) {
      _startSubtreeFadeAnimation(nodeToDelete);
    }
    
    // Main node deletion animation
    final controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    
    animation.addListener(() {
      final progress = animation.value;
      setState(() {
        if (progress < 0.6) {
          // Phase 1: Node shrinks (first 60% of animation)
          _deleteProgress[nodeId] = progress / 0.6;
          _deleteConnectionProgress[nodeId] = 0.0; // Line stays
        } else {
          // Phase 2: Line disappears (last 40% of animation)
          _deleteProgress[nodeId] = 1.0; // Node fully gone
          _deleteConnectionProgress[nodeId] = (progress - 0.6) / 0.4; // Line shrinks back
        }
      });
    });
    
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Cleanup animation state first
        _deletingNodes.remove(nodeId);
        _deleteProgress.remove(nodeId);
        _deleteConnectionProgress.remove(nodeId);
        _animatingNodes.remove(nodeId);
        _originalPositions.remove(nodeId);
        controller.dispose();
        
        // Cleanup subtree fade animations
        _cleanupSubtreeFade(nodeToDelete);
        
        // Execute deletion with smooth layout transition
        _executeDeleteWithTransition(onComplete);
      }
    });
    
    _deletingNodes.add(nodeId);
    _animatingNodes.add(nodeId);
    _deleteProgress[nodeId] = 0.0;
    _deleteConnectionProgress[nodeId] = 0.0;
    
    controller.forward();
  }
  
  // Helper method to find a node by ID in the tree
  TreeNode? _findNodeById(TreeNode? root, String nodeId) {
    if (root == null) return null;
    if (root.id == nodeId) return root;
    
    for (var child in root.children) {
      final found = _findNodeById(child, nodeId);
      if (found != null) return found;
    }
    return null;
  }
  
  // Start fade-out animation for entire subtree
  void _startSubtreeFadeAnimation(TreeNode parentNode) {
    final subtreeController = AnimationController(
      duration: const Duration(milliseconds: 600), // Slightly faster than main deletion
      vsync: this,
    );
    
    final subtreeAnimation = CurvedAnimation(
      parent: subtreeController,
      curve: Curves.easeOut,
    );
    
    // Collect all descendant nodes
    Set<String> subtreeNodeIds = {};
    _collectAllDescendants(parentNode, subtreeNodeIds);
    
    // Add all subtree nodes to fading set
    for (String childId in subtreeNodeIds) {
      _fadingSubtreeNodes.add(childId);
      _subtreeFadeProgress[childId] = 0.0;
    }
    
    subtreeAnimation.addListener(() {
      setState(() {
        for (String childId in subtreeNodeIds) {
          _subtreeFadeProgress[childId] = subtreeAnimation.value;
        }
      });
    });
    
    _nodeAnimations['subtree_${parentNode.id}'] = subtreeController;
    subtreeController.forward();
  }
  
  // Collect all descendant node IDs recursively
  void _collectAllDescendants(TreeNode node, Set<String> descendants) {
    for (var child in node.children) {
      descendants.add(child.id);
      _collectAllDescendants(child, descendants);
    }
  }
  
  // Cleanup subtree fade animations
  void _cleanupSubtreeFade(TreeNode parentNode) {
    Set<String> subtreeNodeIds = {};
    _collectAllDescendants(parentNode, subtreeNodeIds);
    
    for (String childId in subtreeNodeIds) {
      _fadingSubtreeNodes.remove(childId);
      _subtreeFadeProgress.remove(childId);
    }
    
    final subtreeControllerId = 'subtree_${parentNode.id}';
    _nodeAnimations[subtreeControllerId]?.dispose();
    _nodeAnimations.remove(subtreeControllerId);
  }

  // Execute deletion with smooth layout transition
  void _executeDeleteWithTransition(VoidCallback onComplete) {
    // Simple approach: just execute deletion and let the tree naturally re-layout
    onComplete();
    
    // Optional: Add a subtle re-center after deletion
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _recenterTree();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TreeProvider>(
      builder: (context, treeProvider, child) {
        if (treeProvider.root == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            ),
          );
        }

        _rootNode = treeProvider.root;

        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          body: Stack(
            children: [
              // Main InteractiveViewer with built-in scrolling
              InteractiveViewer(
                transformationController: _transformationController,
                minScale: AppConstants.minZoom,
                maxScale: AppConstants.maxZoom,
                boundaryMargin: const EdgeInsets.all(200),
                constrained: false,
                child: Container(
                  width: 5000,
                  height: 3500,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppConstants.backgroundColor,
                        AppConstants.cardColor.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: GestureDetector(
                    onTapUp: (details) {
                      final canvasSize = Size(5000, 3500);
                      _handleTap(details, treeProvider, canvasSize);
                    },
                    child: CustomPaint(
                      size: Size(5000, 3500),
                      painter: TreePainter(
                        root: treeProvider.root!,
                        selectedNode: treeProvider.activeNode,
                        canvasSize: Size(5000, 3500),
                        animatingNodes: _animatingNodes,
                        nodeScales: _getNodeScales(),
                        connectionProgress: _getConnectionProgress(),
                        deletingNodes: _deletingNodes,
                        deleteProgress: _deleteProgress,
                        deleteConnectionProgress: _deleteConnectionProgress,
                        fadingSubtreeNodes: _fadingSubtreeNodes,
                        subtreeFadeProgress: _subtreeFadeProgress,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Controls
              _buildZoomControls(context, treeProvider),
              _buildAddNodeButton(context, treeProvider),
            ],
          ),
        );
      },
    );
  }

  void _handleTap(
      TapUpDetails details, TreeProvider provider, Size canvasSize) {
    final localPosition = details.localPosition;
    final tappedNode =
        _findNodeAtPosition(localPosition, provider.root!, canvasSize);

    if (tappedNode != null) {
      provider.setActiveNode(tappedNode);
    }
  }

  TreeNode? _findNodeAtPosition(
      Offset position, TreeNode root, Size canvasSize) {
    final nodePositions = TreePainter.calculateNodePositions(root, canvasSize);
    const nodeRadius = 30.0;

    for (final entry in nodePositions.entries) {
      final nodePosition = entry.value;
      final distance = (position - nodePosition).distance;
      if (distance <= nodeRadius) {
        return root.findNodeById(entry.key);
      }
    }
    return null;
  }

  Widget _buildAddNodeButton(BuildContext context, TreeProvider provider) {
    // Only show desktop buttons on large screens - mobile has its own compact buttons
    if (widget.isSmallScreen) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: 30,
      left: MediaQuery.of(context).size.width / 2 - 180, // Wider to accommodate three buttons
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Applications Button
          FloatingActionButton.extended(
            heroTag: "applications_button",
            onPressed: () => _showApplicationExamples(context),
            backgroundColor: AppConstants.cardColor,
            foregroundColor: Colors.white,
            elevation: 12,
            icon: const Icon(Icons.apps),
            label: const Text(
              'Applications',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12), // Spacing between buttons
          // Add Node Button
          FloatingActionButton.extended(
            heroTag: "add_node_button",
            onPressed: () {
              final activeNode = provider.activeNode;
              if (activeNode != null) {
                final newNodeId = provider.addChildToActiveNode();
                if (newNodeId != null) {
                  // Start animation immediately to prevent flickering
                  _animateNewNode(newNodeId);
                  // Recenter after animation starts
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      _recenterTree();
                    }
                  });
                }
              }
            },
            backgroundColor: AppConstants.activeNodeColor,
            foregroundColor: Colors.white,
            elevation: 12,
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Node',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12), // Spacing between buttons
          // Recenter Button
          FloatingActionButton.extended(
            heroTag: "recenter_button",
            onPressed: () => _recenterTree(),
            backgroundColor: AppConstants.cobaltBlue,
            foregroundColor: Colors.white,
            elevation: 12,
            icon: const Icon(Icons.center_focus_strong),
            label: const Text(
              'Recenter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls(BuildContext context, TreeProvider provider) {
    // Hide zoom controls on mobile since mobile has pinch-to-zoom
    if (widget.isSmallScreen) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<TreeProvider>(
            builder: (context, treeProvider, child) {
              if (treeProvider.activeNode != null &&
                  treeProvider.activeNode != treeProvider.root) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton(
                    heroTag: "delete_button",
                    onPressed: () {
                      _showDeleteConfirmation(
                          context, treeProvider, treeProvider.activeNode!);
                    },
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    elevation: 10,
                    tooltip: 'Delete Selected Node',
                    child: const Icon(Icons.delete),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Zoom Controls UI
          Container(
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildControlButton(
                  icon: Icons.add,
                  tooltip: 'Zoom In',
                  onPressed: () {
                    final currentScale =
                        _transformationController.value.getMaxScaleOnAxis();
                    final newScale =
                        (currentScale * 1.2).clamp(AppConstants.minZoom, AppConstants.maxZoom);
                    final currentMatrix =
                        _transformationController.value.clone();
                    currentMatrix.scale(newScale / currentScale);
                    _transformationController.value = currentMatrix;
                    _currentScale = newScale;
                  },
                ),
                Divider(
                    color: AppConstants.lightSkyBlue.withOpacity(0.4),
                    thickness: 1,
                    height: 1),
                _buildControlButton(
                  icon: Icons.remove,
                  tooltip: 'Zoom Out',
                  onPressed: () {
                    final currentScale =
                        _transformationController.value.getMaxScaleOnAxis();
                    final newScale =
                        (currentScale * 0.8).clamp(AppConstants.minZoom, AppConstants.maxZoom);
                    final currentMatrix =
                        _transformationController.value.clone();
                    currentMatrix.scale(newScale / currentScale);
                    _transformationController.value = currentMatrix;
                    _currentScale = newScale;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: AppConstants.frenchBlue,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, TreeProvider provider, TreeNode node) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 20,
        backgroundColor: AppConstants.cardColor,
        child: Container(
            constraints: BoxConstraints(
                maxWidth: math.min(MediaQuery.of(context).size.width * 0.8, 350),
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                    AppConstants.cardColor.withOpacity(0.9),
                    AppConstants.backgroundColor.withOpacity(0.9),
                ],
                ),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Icon(Icons.delete_forever, size: 50, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                    'Delete Node',
                    style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.cobaltBlue,
                    ),
                ),
                const SizedBox(height: 12),
                Text(
                    'Are you sure you want to delete node "${node.label}" and all its children?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 16,
                    color: AppConstants.frenchBlue,
                    ),
                ),
                const SizedBox(height: 24),
                Row(
                    children: [
                    Expanded(
                        child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            ),
                        ),
                        child: Text(
                            'Cancel',
                            style: TextStyle(
                            fontSize: 16,
                            color: AppConstants.frenchBlue,
                            ),
                        ),
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton(
                        onPressed: () {
                            Navigator.of(context).pop();
                            // Animate deletion before actually deleting
                            _animateDeleteNode(node.id, () {
                              provider.deleteNode(node);
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (mounted) {
                                  _recenterTree();
                                }
                              });
                            });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                        ),
                        child: const Text(
                            'Delete',
                            style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            ),
                        ),
                        ),
                    ),
                    ],
                ),
                ],
            ),
        ),

      ),
    );
  }

  /// Recenter (unchanged except theme colors are consistent)
  /// Recenter tree ensuring root node stays at screen center
  void _recenterTree({bool animated = true}) {
    final treeProvider = Provider.of<TreeProvider>(context, listen: false);
    if (treeProvider.root == null) return;
    _rootNode = treeProvider.root;

    final screenSize = MediaQuery.of(context).size;
    final canvasSize = Size(5000, 3500); // Match the canvas size

    final nodePositions = TreePainter.calculateNodePositions(_rootNode!, canvasSize);
    if (nodePositions.isEmpty) return;

    const nodeRadius = 30.0;
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

    for (final pos in nodePositions.values) {
      minX = math.min(minX, pos.dx - nodeRadius);
      maxX = math.max(maxX, pos.dx + nodeRadius);
      minY = math.min(minY, pos.dy - nodeRadius);
      maxY = math.max(maxY, pos.dy + nodeRadius);
    }

    final treeWidth = math.max(1, maxX - minX);
    final treeHeight = math.max(1, maxY - minY);
    
    // Calculate optimal scale to fit the tree with some padding
    final scaleX = (screenSize.width * 0.85) / treeWidth; // 85% width usage
    final scaleY = (screenSize.height * 0.8) / treeHeight; // 80% height usage
    final optimalScale = math.min(scaleX, scaleY).clamp(AppConstants.minZoom, AppConstants.maxZoom);
    
    // Always center root node horizontally and position it optimally vertically
    final rootPos = nodePositions[_rootNode!.id]!;
    final targetRootX = screenSize.width / 2; // Always center horizontally
    final targetRootY = screenSize.height * 0.2; // 20% from top for better visibility
    
    // Calculate translation to position root at target location
    final translateX = targetRootX - (rootPos.dx * optimalScale);
    final translateY = targetRootY - (rootPos.dy * optimalScale);

    final targetMatrix = Matrix4.identity()
      ..translate(translateX, translateY)
      ..scale(optimalScale);

    if (animated && mounted) {
      final begin = _transformationController.value;
      final end = targetMatrix;

      final animation = Matrix4Tween(begin: begin, end: end).animate(
        CurvedAnimation(
            parent: _recenterAnimationController, curve: Curves.easeInOutCubic),
      );

      _recenterAnimationController.reset();
      _recenterAnimationController.forward();

      void listener() {
        if (!mounted) return;
        _transformationController.value = animation.value;
      }

      _recenterAnimationController.addListener(listener);
      _recenterAnimationController.addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          _recenterAnimationController.removeListener(listener);
        }
      });
    } else {
      _transformationController.value = targetMatrix;
    }

    _currentScale = optimalScale;
    if (mounted) setState(() {});
  }

  void _showApplicationExamples(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: const ApplicationExamples(),
      ),
    );
  }

  // Public methods for mobile controls to use
  void addNodeWithAnimation() {
    final provider = Provider.of<TreeProvider>(context, listen: false);
    final activeNode = provider.activeNode;
    if (activeNode != null) {
      final newNodeId = provider.addChildToActiveNode();
      if (newNodeId != null) {
        // Start animation immediately to prevent flickering
        _animateNewNode(newNodeId);
        // Recenter after animation starts
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _recenterTree();
          }
        });
      }
    }
  }

  void recenterTreeAnimated() {
    _recenterTree();
  }

  void showApplicationExamples() {
    _showApplicationExamples(context);
  }
}

/// Custom painter
class TreePainter extends CustomPainter {
  final TreeNode root;
  final TreeNode? selectedNode;
  final Size canvasSize;
  final Set<String> animatingNodes;
  final Map<String, double> nodeScales;
  final Map<String, double> connectionProgress;
  final Set<String> deletingNodes;
  final Map<String, double> deleteProgress;
  final Map<String, double> deleteConnectionProgress;
  final Set<String> fadingSubtreeNodes;
  final Map<String, double> subtreeFadeProgress;

  static Map<String, Offset> _cachedPositions = {};

  TreePainter({
    required this.root,
    this.selectedNode,
    required this.canvasSize,
    this.animatingNodes = const {},
    this.nodeScales = const {},
    this.connectionProgress = const {},
    this.deletingNodes = const {},
    this.deleteProgress = const {},
    this.deleteConnectionProgress = const {},
    this.fadingSubtreeNodes = const {},
    this.subtreeFadeProgress = const {},
  });

  static Map<String, Offset> calculateNodePositions(
      TreeNode root, 
      Size canvasSize) {
    
    _cachedPositions.clear();

    const double levelHeight = 100.0;
    const double minNodeSpacing = 80.0;

    Map<int, List<TreeNode>> levels = {};
    Map<TreeNode, double> subtreeWidths = {};

    _assignLevels(root, 0, levels);
    _calculateSubtreeWidths(root, subtreeWidths, minNodeSpacing);

    double centerX = canvasSize.width / 2;
    double startY = 150.0;

    _cachedPositions[root.id] = Offset(centerX, startY);

    for (int level = 1; level < levels.length; level++) {
      double currentY = startY + (level * levelHeight);
      for (TreeNode node in levels[level]!) {
        if (node.parent != null) {
          _positionNodeWithParent(
              node, currentY, minNodeSpacing, subtreeWidths);
        }
      }
    }

    return _cachedPositions;
  }

  static void _assignLevels(
      TreeNode node, int level, Map<int, List<TreeNode>> levels) {
    levels.putIfAbsent(level, () => []).add(node);
    for (TreeNode child in node.children) {
      _assignLevels(child, level + 1, levels);
    }
  }

  static void _calculateSubtreeWidths(
      TreeNode node, Map<TreeNode, double> widths, double minSpacing) {
    if (node.children.isEmpty) {
      widths[node] = minSpacing;
      return;
    }

    double totalChildWidth = 0;
    for (TreeNode child in node.children) {
      _calculateSubtreeWidths(child, widths, minSpacing);
      totalChildWidth += widths[child]!;
    }

    widths[node] = math.max(
        minSpacing * 1.5,
        totalChildWidth + (node.children.length - 1) * minSpacing * 0.3);
  }

  static void _positionNodeWithParent(TreeNode node, double yPosition,
      double minSpacing, Map<TreeNode, double> subtreeWidths) {
    final parent = node.parent!;
    final siblings = parent.children;
    final nodeIndex = siblings.indexOf(node);
    final parentPos = _cachedPositions[parent.id]!;

    if (siblings.length == 1) {
      _cachedPositions[node.id] = Offset(parentPos.dx, yPosition);
    } else {
      double totalWidth = 0;
      for (TreeNode sibling in siblings) {
        totalWidth += subtreeWidths[sibling] ?? minSpacing;
      }

      double startX = parentPos.dx - (totalWidth / 2);
      double currentX = startX;

      for (int i = 0; i < nodeIndex; i++) {
        currentX += subtreeWidths[siblings[i]] ?? minSpacing;
      }
      currentX += (subtreeWidths[node] ?? minSpacing) / 2;

      _cachedPositions[node.id] = Offset(currentX, yPosition);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final nodePositions = TreePainter.calculateNodePositions(
      root, 
      canvasSize,
    );

    _drawGrid(canvas, size);
    _drawConnections(canvas, root, nodePositions);
    _drawNodes(canvas, root, nodePositions);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConstants.lightSkyBlue.withOpacity(0.08)
      ..strokeWidth = 1;

    const double gridSize = 50;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawConnections(
      Canvas canvas, TreeNode node, Map<String, Offset> nodePositions) {
    final nodePos = nodePositions[node.id];
    if (nodePos == null) return;

    for (TreeNode child in node.children) {
      final childPos = nodePositions[child.id];
      if (childPos != null) {
        
        // Base connection color and style
        double connectionOpacity = 0.6;
        
        // Check if child is part of fading subtree
        final isFadingSubtree = fadingSubtreeNodes.contains(child.id);
        final subtreeFadeValue = subtreeFadeProgress[child.id] ?? 0.0;
        
        if (isFadingSubtree) {
          // Fade the connection along with the subtree
          connectionOpacity = connectionOpacity * (1.0 - subtreeFadeValue);
        }
        
        final paint = Paint()
          ..color = AppConstants.cobaltBlue.withOpacity(connectionOpacity)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square;

        // Glowing paint for animated connections (also faded if needed)
        final glowPaint = Paint()
          ..color = AppConstants.activeNodeColor.withOpacity(0.4 * (connectionOpacity / 0.6))
          ..strokeWidth = 4.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0);

        final midY = nodePos.dy + (childPos.dy - nodePos.dy) * 0.5;
        
        // Check if this connection is being animated
        final animationProgress = connectionProgress[child.id] ?? 1.0;
        final isAnimating = connectionProgress.containsKey(child.id) && animationProgress < 1.0;
        
        // Check if this is being deleted (reverse animation)
        final deleteConnectionProgress = this.deleteConnectionProgress[child.id] ?? 0.0;
        final isDeletingConnection = this.deleteConnectionProgress.containsKey(child.id);
        
        if (isAnimating) {
          // Draw animated connection line growing from parent to child
          _drawAnimatedConnection(canvas, nodePos, childPos, midY, animationProgress, paint, glowPaint);
        } else if (isDeletingConnection) {
          // Draw reverse animated connection (shrinking back to parent)
          _drawReverseAnimatedConnection(canvas, nodePos, childPos, midY, deleteConnectionProgress, paint);
        } else {
          // Draw normal static connection
          _drawStaticConnection(canvas, nodePos, childPos, midY, paint);
        }
      }
      _drawConnections(canvas, child, nodePositions);
    }
  }

  void _drawAnimatedConnection(Canvas canvas, Offset parentPos, Offset childPos, double midY, 
      double progress, Paint paint, Paint glowPaint) {
    
    // Use solid paint only - no glow effects
    final solidPaint = Paint()
      ..color = AppConstants.cobaltBlue.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    
    // Calculate the path segments
    final segment1End = Offset(parentPos.dx, midY);
    final segment2End = Offset(childPos.dx, midY);
    final segment3End = Offset(childPos.dx, childPos.dy);
    
    // Total path length (approximated)
    final totalLength = (midY - parentPos.dy) + (childPos.dx - parentPos.dx).abs() + (childPos.dy - midY);
    final currentLength = totalLength * progress;
    
    double remainingLength = currentLength;
    
    // Segment 1: Vertical line down from parent
    final segment1Length = midY - parentPos.dy;
    if (remainingLength > 0) {
      final segment1Progress = math.min(remainingLength / segment1Length, 1.0);
      final segment1EndPoint = Offset(parentPos.dx, parentPos.dy + segment1Length * segment1Progress);
      
      // Draw simple solid line
      canvas.drawLine(parentPos, segment1EndPoint, solidPaint);
      
      remainingLength -= segment1Length * segment1Progress;
    }
    
    // Segment 2: Horizontal line to child x position
    if (remainingLength > 0) {
      final segment2Length = (childPos.dx - parentPos.dx).abs();
      if (segment2Length > 0) {
        final segment2Progress = math.min(remainingLength / segment2Length, 1.0);
        final segment2StartX = parentPos.dx;
        final segment2EndX = parentPos.dx + (childPos.dx - parentPos.dx) * segment2Progress;
        
        final segment2Start = Offset(segment2StartX, midY);
        final segment2EndPoint = Offset(segment2EndX, midY);
        
        // Draw simple solid line
        canvas.drawLine(segment2Start, segment2EndPoint, solidPaint);
        
        remainingLength -= segment2Length * segment2Progress;
      }
    }
    
    // Segment 3: Vertical line down to child
    if (remainingLength > 0) {
      final segment3Length = childPos.dy - midY;
      if (segment3Length > 0) {
        final segment3Progress = math.min(remainingLength / segment3Length, 1.0);
        final segment3Start = Offset(childPos.dx, midY);
        final segment3EndPoint = Offset(childPos.dx, midY + segment3Length * segment3Progress);
        
        // Draw simple solid line
        canvas.drawLine(segment3Start, segment3EndPoint, solidPaint);
      }
    }
  }

  void _drawStaticConnection(Canvas canvas, Offset parentPos, Offset childPos, double midY, Paint paint) {
    // Standard organizational chart connections
    canvas.drawLine(Offset(parentPos.dx, parentPos.dy), Offset(parentPos.dx, midY), paint);
    canvas.drawLine(Offset(parentPos.dx, midY), Offset(childPos.dx, midY), paint);
    canvas.drawLine(Offset(childPos.dx, midY), Offset(childPos.dx, childPos.dy), paint);
  }

  // Reverse animated connection for deletion (shrinks back to parent)
  void _drawReverseAnimatedConnection(Canvas canvas, Offset parentPos, Offset childPos, double midY, 
      double progress, Paint paint) {
    
    // Use same solid paint as static connections
    final solidPaint = Paint()
      ..color = AppConstants.cobaltBlue.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    
    // Progress 0 = full line, Progress 1 = no line (shrunk back to parent)
    final remainingProgress = 1.0 - progress;
    
    // Calculate total path length
    final totalLength = (midY - parentPos.dy) + (childPos.dx - parentPos.dx).abs() + (childPos.dy - midY);
    final currentLength = totalLength * remainingProgress;
    
    double remainingLength = currentLength;
    
    // Segment 1: Vertical line down from parent (always drawn first)
    final segment1Length = midY - parentPos.dy;
    if (remainingLength > 0 && segment1Length > 0) {
      final segment1Progress = math.min(remainingLength / segment1Length, 1.0);
      final segment1EndPoint = Offset(parentPos.dx, parentPos.dy + segment1Length * segment1Progress);
      
      canvas.drawLine(parentPos, segment1EndPoint, solidPaint);
      remainingLength -= segment1Length * segment1Progress;
    }
    
    // Segment 2: Horizontal line to child x position
    if (remainingLength > 0) {
      final segment2Length = (childPos.dx - parentPos.dx).abs();
      if (segment2Length > 0) {
        final segment2Progress = math.min(remainingLength / segment2Length, 1.0);
        final segment2StartX = parentPos.dx;
        final segment2EndX = parentPos.dx + (childPos.dx - parentPos.dx) * segment2Progress;
        
        final segment2Start = Offset(segment2StartX, midY);
        final segment2EndPoint = Offset(segment2EndX, midY);
        
        canvas.drawLine(segment2Start, segment2EndPoint, solidPaint);
        remainingLength -= segment2Length * segment2Progress;
      }
    }
    
    // Segment 3: Vertical line down to child
    if (remainingLength > 0) {
      final segment3Length = childPos.dy - midY;
      if (segment3Length > 0) {
        final segment3Progress = math.min(remainingLength / segment3Length, 1.0);
        final segment3Start = Offset(childPos.dx, midY);
        final segment3EndPoint = Offset(childPos.dx, midY + segment3Length * segment3Progress);
        
        canvas.drawLine(segment3Start, segment3EndPoint, solidPaint);
      }
    }
  }

  void _drawNodes(
      Canvas canvas, TreeNode node, Map<String, Offset> nodePositions) {
    final nodePos = nodePositions[node.id];
    if (nodePos == null) return;

    const double nodeRadius = 30.0;
    final isSelected = node == selectedNode;
    final isRoot = node.parent == null;
    
    // Get animation scales
    double animationScale = nodeScales[node.id] ?? 1.0;
    final isDeleting = deletingNodes.contains(node.id);
    final deleteProgressValue = deleteProgress[node.id] ?? 0.0;
    
    // Check if this node is part of a fading subtree
    final isFadingSubtree = fadingSubtreeNodes.contains(node.id);
    final subtreeFadeValue = subtreeFadeProgress[node.id] ?? 0.0;
    
    // Apply deletion effects - simple and clean
    if (isDeleting) {
      // Scale down with simple fade (no rotation, no particles)
      animationScale = 1.0 - deleteProgressValue;
    }
    
    // Apply scaling animation
    final animatedRadius = nodeRadius * animationScale;
    
    // Skip drawing if completely scaled down
    if (animationScale <= 0.001) {
      // Still draw children
      for (TreeNode child in node.children) {
        _drawNodes(canvas, child, nodePositions);
      }
      return;
    }

    // Choose node color with deletion fade
    Color nodeColor = isRoot 
        ? AppConstants.primaryColor 
        : (isSelected ? AppConstants.activeNodeColor : AppConstants.cobaltBlue);
    
    // Apply deletion fade for main node
    if (isDeleting) {
      final opacity = (1.0 - deleteProgressValue).clamp(0.0, 1.0);
      nodeColor = nodeColor.withOpacity(opacity);
    }
    
    // Apply subtree fade-out effect
    if (isFadingSubtree) {
      final opacity = (1.0 - subtreeFadeValue).clamp(0.0, 1.0);
      nodeColor = nodeColor.withOpacity(nodeColor.opacity * opacity);
    }

    final nodePaint = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.fill;

    // Draw node with animation scale
    canvas.drawCircle(nodePos, animatedRadius, nodePaint);

    // Draw selection border with animation
    if (isSelected && animationScale > 0.5 && !isDeleting) {
      final borderOpacity = animationScale.clamp(0.0, 1.0);
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(borderOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * animationScale;
      canvas.drawCircle(nodePos, animatedRadius, borderPaint);
    }

    // Remove the bad blinking glow effect - keep it simple

    // Apply deletion effects - simple and clean
    if (isDeleting) {
      // Scale down with simple fade (no rotation, no particles)
      animationScale = 1.0 - deleteProgressValue;
      
      // Simple fade without complex transformations
    }

    // Draw text with opacity based on scale
    if (animationScale > 0.3) {
      double textOpacity = animationScale.clamp(0.0, 1.0);
      if (isDeleting) textOpacity *= (1.0 - deleteProgressValue).clamp(0.0, 1.0);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.label,
          style: TextStyle(
            color: Colors.white.withOpacity(textOpacity.clamp(0.0, 1.0)),
            fontSize: 14 * math.min(animationScale, 1.0),
            fontWeight: isRoot ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final textOffset = Offset(
        nodePos.dx - textPainter.width / 2,
        nodePos.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }

    // Draw children
    for (TreeNode child in node.children) {
      _drawNodes(canvas, child, nodePositions);
    }
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.root != root ||
        oldDelegate.selectedNode != selectedNode ||
        oldDelegate.canvasSize != canvasSize ||
        oldDelegate.animatingNodes != animatingNodes ||
        oldDelegate.nodeScales != nodeScales ||
        oldDelegate.connectionProgress != connectionProgress ||
        oldDelegate.deletingNodes != deletingNodes ||
        oldDelegate.deleteProgress != deleteProgress ||
        oldDelegate.deleteConnectionProgress != deleteConnectionProgress;
  }
}
