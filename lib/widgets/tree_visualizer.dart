import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/tree_node.dart';
import '../providers/tree_provider.dart';
import '../utils/constants.dart';
import 'node_widget.dart';
import 'package:provider/provider.dart';

class TreeVisualizer extends StatefulWidget {
  const TreeVisualizer({Key? key}) : super(key: key);

  @override
  State<TreeVisualizer> createState() => _TreeVisualizerState();
}

class _TreeVisualizerState extends State<TreeVisualizer>
    with TickerProviderStateMixin {
  Map<String, Offset> nodePositions = {};
  late AnimationController _layoutAnimationController;

  @override
  void initState() {
    super.initState();
    _layoutAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _layoutAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TreeProvider>(
      builder: (context, treeProvider, child) {
        if (treeProvider.root == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            _calculateNodePositions(treeProvider.root!, constraints);
            
            return Stack(
              children: [
                // Draw connections
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: ConnectionPainter(
                    nodePositions: nodePositions,
                    root: treeProvider.root!,
                  ),
                ),
                // Draw nodes
                ...treeProvider.root!.getAllNodes().map((node) {
                  final position = nodePositions[node.id] ?? Offset.zero;
                  return NodeWidget(
                    key: ValueKey(node.id),
                    node: node,
                    isActive: node == treeProvider.activeNode,
                    position: position,
                    onTap: () => treeProvider.setActiveNode(node),
                    onDelete: () => treeProvider.deleteNode(node),
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

  void _calculateNodePositions(TreeNode root, BoxConstraints constraints) {
    const double levelHeight = 120.0;
    const double minNodeSpacing = 80.0;

    // Calculate tree layout using a simple algorithm
    Map<int, List<TreeNode>> levels = {};
    _assignLevels(root, 0, levels);

    double centerX = constraints.maxWidth / 2;
    double startY = 80.0;

    for (int level in levels.keys) {
      List<TreeNode> nodesInLevel = levels[level]!;
      double totalWidth = (nodesInLevel.length - 1) * minNodeSpacing;
      double startX = centerX - totalWidth / 2;

      for (int i = 0; i < nodesInLevel.length; i++) {
        TreeNode node = nodesInLevel[i];
        double x = startX + (i * minNodeSpacing);
        double y = startY + (level * levelHeight);

        nodePositions[node.id] = Offset(x, y);
      }
    }
  }

  void _assignLevels(TreeNode node, int level, Map<int, List<TreeNode>> levels) {
    levels.putIfAbsent(level, () => []).add(node);
    for (TreeNode child in node.children) {
      _assignLevels(child, level + 1, levels);
    }
  }
}

class ConnectionPainter extends CustomPainter {
  final Map<String, Offset> nodePositions;
  final TreeNode root;

  ConnectionPainter({
    required this.nodePositions,
    required this.root,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConstants.connectionColor
      ..strokeWidth = AppConstants.connectionStroke
      ..style = PaintingStyle.stroke;

    _drawConnections(canvas, paint, root);
  }

  void _drawConnections(Canvas canvas, Paint paint, TreeNode node) {
    final nodePos = nodePositions[node.id];
    if (nodePos == null) return;

    for (TreeNode child in node.children) {
      final childPos = nodePositions[child.id];
      if (childPos != null) {
        canvas.drawLine(nodePos, childPos, paint);
        _drawConnections(canvas, paint, child);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}