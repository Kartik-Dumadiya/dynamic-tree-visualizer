import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tree_provider.dart';
import '../widgets/tree_visualizer.dart';
import '../widgets/application_examples.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  final bool isSmallScreen;
  final bool isMediumScreen;
  final bool isLargeScreen;
  final bool isLandscape;
  final double screenWidth;
  final double screenHeight;
  
  const HomeScreen({
    Key? key,
    required this.isSmallScreen,
    required this.isMediumScreen,
    required this.isLargeScreen,
    required this.isLandscape,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Responsive app bar height
    final double appBarHeight = widget.isSmallScreen ? 60 : 80;
    
    return Scaffold(
      backgroundColor: AppConstants.darkBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: appBarHeight,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppConstants.darkBackground,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppConstants.darkBackground,
                      AppConstants.nodeInactiveStart,
                    ],
                  ),
                ),
              ),
              centerTitle: true,
              title: Text(
                'Dynamic Tree Visualizer',
                style: TextStyle(
                  fontFamily: "RobotoMono",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.isSmallScreen ? 12 : 16,
                ),
              ),
              actions: [
                // Responsive action buttons
                _buildResponsiveActionButton(
                  icon: Icons.help_outline,
                  onPressed: () => _showInstructions(context),
                  tooltip: 'How to Use',
                ),
                _buildResponsiveActionButton(
                  icon: Icons.refresh,
                  onPressed: () {
                    context.read<TreeProvider>().resetTree();
                  },
                  tooltip: 'Reset Tree',
                ),
              ],
            ),
          ];
        },
        body: ResponsiveTreeVisualizer(
          isSmallScreen: widget.isSmallScreen,
          isMediumScreen: widget.isMediumScreen,
          isLargeScreen: widget.isLargeScreen,
          isLandscape: widget.isLandscape,
          screenWidth: widget.screenWidth,
          screenHeight: widget.screenHeight,
        ),
      ),
    );
  }

  Widget _buildResponsiveActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isSmallScreen ? 4.0 : 8.0,
        ),
        child: IconButton(
          icon: Icon(
            icon,
            color: Colors.white,
            size: widget.isSmallScreen ? 20 : 24,
          ),
          onPressed: onPressed,
          splashRadius: widget.isSmallScreen ? 20 : 24,
        ),
      ),
    );
  }

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isSmallDialog = constraints.maxWidth < 600;
            final bool isLandscapeDialog = constraints.maxWidth > constraints.maxHeight;
            
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(isSmallDialog ? 16 : 20),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isSmallDialog ? double.infinity : 600,
                  maxHeight: constraints.maxHeight * (isSmallDialog ? 0.9 : 0.85),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppConstants.darkBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Responsive header
                    _buildResponsiveHeader(isSmallDialog),
                    
                    // Content area with responsive padding
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isSmallDialog ? 16 : 20),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInstructionSection(
                                'Basic Operations',
                                [
                                  _buildResponsiveInstructionCard(
                                    icon: Icons.touch_app,
                                    iconColor: Colors.orange,
                                    title: 'Select Node',
                                    description: 'Tap any node to select it',
                                    details: 'Selected nodes are highlighted in orange with pulsing animation',
                                    isSmall: isSmallDialog,
                                  ),
                                  _buildResponsiveInstructionCard(
                                    icon: Icons.add_circle,
                                    iconColor: Colors.green,
                                    title: 'Add Node',
                                    description: 'Add a child to the selected node',
                                    details: 'Use the "Add Node" button at the bottom center',
                                    isSmall: isSmallDialog,
                                  ),
                                  _buildResponsiveInstructionCard(
                                    icon: Icons.delete,
                                    iconColor: Colors.red,
                                    title: 'Delete Node',
                                    description: 'Remove node and its children',
                                    details: 'Select a node (not root) and use the red delete button in zoom controls',
                                    isSmall: isSmallDialog,
                                  ),
                                ],
                                isSmall: isSmallDialog,
                              ),
                              SizedBox(height: isSmallDialog ? 16 : 20),
                              _buildInstructionSection(
                                'Navigation Controls',
                                [
                                  _buildResponsiveInstructionCard(
                                    icon: Icons.pan_tool,
                                    iconColor: Colors.blue,
                                    title: 'Zoom & Pan',
                                    description: 'Navigate around the tree',
                                    details: 'Pinch to zoom in/out, drag to pan around the tree canvas',
                                    isSmall: isSmallDialog,
                                  ),
                                  _buildResponsiveInstructionCard(
                                    icon: Icons.control_camera,
                                    iconColor: Colors.purple,
                                    title: 'Zoom Controls',
                                    description: 'Precise zoom control',
                                    details: 'Bottom-right buttons: + (zoom in), - (zoom out), ⌖ (recenter)',
                                    isSmall: isSmallDialog,
                                  ),
                                  _buildResponsiveInstructionCard(
                                    icon: Icons.center_focus_strong,
                                    iconColor: Colors.teal,
                                    title: 'Recenter Tree',
                                    description: 'Auto-center the tree view',
                                    details: 'Click the recenter button (⌖) to fit the tree perfectly in view',
                                    isSmall: isSmallDialog,
                                  ),
                                ],
                                isSmall: isSmallDialog,
                              ),
                              SizedBox(height: isSmallDialog ? 16 : 20),
                              _buildInstructionSection(
                                'Other Features',
                                [
                                  _buildResponsiveInstructionCard(
                                    icon: Icons.refresh,
                                    iconColor: Colors.amber,
                                    title: 'Reset Tree',
                                    description: 'Start over with clean slate',
                                    details: 'Use the refresh button in top-right to reset to just the root node',
                                    isSmall: isSmallDialog,
                                  ),
                                ],
                                isSmall: isSmallDialog,
                              ),
                              SizedBox(height: isSmallDialog ? 12 : 16),
                              // Responsive tip section
                              _buildResponsiveTipSection(isSmallDialog),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResponsiveHeader(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.activeNodeColor.withOpacity(0.8),
            AppConstants.activeNodeColor.withOpacity(0.6),
          ],
        ),
      ),
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmall ? 6 : 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
            ),
            child: Icon(
              Icons.help_outline,
              size: isSmall ? 24 : 28,
              color: Colors.white,
            ),
          ),
          SizedBox(width: isSmall ? 12 : 16),
          Expanded(
            child: Text(
              'How to Use',
              style: TextStyle(
                fontFamily: "RobotoMono",
                fontSize: isSmall ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(isSmall ? 16 : 20),
            ),
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: isSmall ? 18 : 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
              splashRadius: isSmall ? 18 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTipSection(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: AppConstants.activeNodeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.activeNodeColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppConstants.activeNodeColor,
            size: isSmall ? 20 : 24,
          ),
          SizedBox(width: isSmall ? 8 : 12),
          Expanded(
            child: Text(
              'Tip: You can build complex tree structures by selecting different nodes and adding children at various levels!',
              style: TextStyle(
                fontFamily: "RobotoMono",
                fontSize: isSmall ? 12 : 13,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionSection(String title, List<Widget> cards, {required bool isSmall}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: isSmall ? 8 : 12),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "RobotoMono",
              fontSize: isSmall ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.activeNodeColor,
            ),
          ),
        ),
        ...cards,
      ],
    );
  }

  Widget _buildResponsiveInstructionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String details,
    required bool isSmall,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmall ? 8 : 12),
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: AppConstants.nodeInactiveStart.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.nodeBorder.withOpacity(0.3),
        ),
      ),
      child: isSmall 
        ? _buildCompactCardLayout(icon, iconColor, title, description, details)
        : _buildFullCardLayout(icon, iconColor, title, description, details, isSmall),
    );
  }

  Widget _buildCompactCardLayout(IconData icon, Color iconColor, String title, String description, String details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "RobotoMono",
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: "RobotoMono",
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            details,
            style: const TextStyle(
              fontFamily: "RobotoMono",
              fontSize: 11,
              color: Colors.white60,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullCardLayout(IconData icon, Color iconColor, String title, String description, String details, bool isSmall) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container
        Container(
          padding: EdgeInsets.all(isSmall ? 6 : 8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: isSmall ? 20 : 24,
            color: iconColor,
          ),
        ),
        SizedBox(width: isSmall ? 12 : 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: "RobotoMono",
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 14 : 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isSmall ? 2 : 4),
              Text(
                description,
                style: TextStyle(
                  fontFamily: "RobotoMono",
                  fontSize: isSmall ? 12 : 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isSmall ? 4 : 6),
              Text(
                details,
                style: TextStyle(
                  fontFamily: "RobotoMono",
                  fontSize: isSmall ? 10 : 12,
                  color: Colors.white60,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Responsive wrapper for TreeVisualizer
class ResponsiveTreeVisualizer extends StatelessWidget {
  final bool isSmallScreen;
  final bool isMediumScreen;
  final bool isLargeScreen;
  final bool isLandscape;
  final double screenWidth;
  final double screenHeight;

  // GlobalKey to access TreeVisualizer methods
  final GlobalKey<TreeVisualizerState> _treeVisualizerKey = GlobalKey<TreeVisualizerState>();

  ResponsiveTreeVisualizer({
    Key? key,
    required this.isSmallScreen,
    required this.isMediumScreen,
    required this.isLargeScreen,
    required this.isLandscape,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main tree visualizer with responsive parameters
        TreeVisualizer(
          key: _treeVisualizerKey,
          isSmallScreen: isSmallScreen,
          isMediumScreen: isMediumScreen,
          isLargeScreen: isLargeScreen,
        ),
        
        // Responsive floating action buttons for mobile
        if (isSmallScreen) _buildMobileControls(context),
        
        // Desktop controls are handled within TreeVisualizer itself
      ],
    );
  }

  Widget _buildMobileControls(BuildContext context) {
    return Consumer<TreeProvider>(
      builder: (context, treeProvider, child) {
        final hasActiveNode = treeProvider.activeNode != null && 
                              treeProvider.activeNode != treeProvider.root;
        
        return Stack(
          children: [
            // Main button bar (always visible)
            Positioned(
              bottom: isLandscape ? 16 : 24,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Reduced padding
                  decoration: BoxDecoration(
                    color: AppConstants.darkBackground.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Applications button (icon only)
                      _buildProfessionalMobileButton(
                        icon: Icons.apps,
                        label: null, // No label - icon only
                        onPressed: () => _showApplications(context),
                        color: AppConstants.activeNodeColor,
                        isWide: false,
                      ),
                      
                      // Add node button (with label, wider)
                      _buildProfessionalMobileButton(
                        icon: Icons.add,
                        label: 'Add Node', // Only this button shows label
                        onPressed: () => _addNode(context),
                        color: Colors.green.shade600,
                        isWide: true,
                      ),
                      
                      // Recenter button (icon only)
                      _buildProfessionalMobileButton(
                        icon: Icons.center_focus_strong,
                        label: null, // No label - icon only
                        onPressed: () => _recenterTree(context),
                        color: Colors.blue.shade600,
                        isWide: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Separate delete button (positioned outside, only when needed)
            if (hasActiveNode)
              Positioned(
                bottom: isLandscape ? 80 : 88, // Above the main button bar
                right: 20,
                child: SafeArea(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _deleteNode(context),
                        borderRadius: BorderRadius.circular(28),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfessionalMobileButton({
    required IconData icon,
    required String? label, // Made nullable for icon-only buttons
    required VoidCallback onPressed,
    required Color color,
    required bool isWide,
  }) {
    return Expanded(
      flex: isWide ? 2 : 1, // Add button takes 2x space, others take 1x
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2), // Reduced margin
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(25),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Reduced padding
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 18, // Reduced icon size slightly
                  ),
                  // Only show label if provided
                  if (label != null) ...[
                    const SizedBox(width: 6), // Reduced spacing
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: "RobotoMono",
                          fontSize: 11, // Reduced font size
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showApplications(BuildContext context) {
    // Use TreeVisualizer's method for consistent behavior
    _treeVisualizerKey.currentState?.showApplicationExamples();
  }

  void _addNode(BuildContext context) {
    // Use TreeVisualizer's method with animations
    _treeVisualizerKey.currentState?.addNodeWithAnimation();
  }

  void _deleteNode(BuildContext context) {
    // Use TreeVisualizer's method for delete with confirmation
    _treeVisualizerKey.currentState?.showDeleteConfirmationMobile();
  }

  void _recenterTree(BuildContext context) {
    // Use TreeVisualizer's method with proper animation
    _treeVisualizerKey.currentState?.recenterTreeAnimated();
  }
}
