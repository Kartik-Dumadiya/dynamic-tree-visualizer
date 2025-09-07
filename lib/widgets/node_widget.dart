import 'package:flutter/material.dart';
import '../models/tree_node.dart';
import '../utils/constants.dart';

class NodeWidget extends StatefulWidget {
  final TreeNode node;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Offset position;

  const NodeWidget({
    Key? key,
    required this.node,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
    required this.position,
  }) : super(key: key);

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - (widget.isActive ? AppConstants.activeNodeSize : AppConstants.nodeSize) / 2,
      top: widget.position.dy - (widget.isActive ? AppConstants.activeNodeSize : AppConstants.nodeSize) / 2,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: () => _showDeleteDialog(context),
          child: AnimatedContainer(
            duration: AppConstants.animationDuration,
            width: widget.isActive ? AppConstants.activeNodeSize : AppConstants.nodeSize,
            height: widget.isActive ? AppConstants.activeNodeSize : AppConstants.nodeSize,
            decoration: BoxDecoration(
              color: widget.isActive ? AppConstants.activeNodeColor : AppConstants.nodeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: widget.isActive ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: widget.isActive
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
            ),
            child: Center(
              child: Text(
                widget.node.label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.isActive ? 18 : 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Node'),
          content: Text('Are you sure you want to delete node "${widget.node.label}" and all its children?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}