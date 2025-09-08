// import 'package:flutter/material.dart';
// import '../models/tree_node.dart';
// import '../utils/constants.dart';

// class NodeWidget extends StatefulWidget {
//   final TreeNode node;
//   final bool isActive;
//   final VoidCallback onTap;
//   final VoidCallback onDelete;
//   final Offset position;
//   final double scale;

//   const NodeWidget({
//     Key? key,
//     required this.node,
//     required this.isActive,
//     required this.onTap,
//     required this.onDelete,
//     required this.position,
//     this.scale = 1.0,
//   }) : super(key: key);

//   @override
//   State<NodeWidget> createState() => _NodeWidgetState();
// }

// class _NodeWidgetState extends State<NodeWidget>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleAnimationController;
//   late AnimationController _pulseAnimationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _pulseAnimation;
//   late Animation<Color?> _colorAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     // Scale animation for node creation
//     _scaleAnimationController = AnimationController(
//       duration: AppConstants.animationDuration,
//       vsync: this,
//     );
    
//     _scaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _scaleAnimationController,
//       curve: Curves.elasticOut,
//     ));

//     // Pulse animation for active node
//     _pulseAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
    
//     _pulseAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.1,
//     ).animate(CurvedAnimation(
//       parent: _pulseAnimationController,
//       curve: Curves.easeInOut,
//     ));

//     // Color animation
//     _colorAnimation = ColorTween(
//       begin: AppConstants.nodeColor,
//       end: AppConstants.activeNodeColor,
//     ).animate(CurvedAnimation(
//       parent: _pulseAnimationController,
//       curve: Curves.easeInOut,
//     ));

//     _scaleAnimationController.forward();
    
//     if (widget.isActive) {
//       _pulseAnimationController.repeat(reverse: true);
//     }
//   }

//   @override
//   void didUpdateWidget(NodeWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isActive && !oldWidget.isActive) {
//       _pulseAnimationController.repeat(reverse: true);
//     } else if (!widget.isActive && oldWidget.isActive) {
//       _pulseAnimationController.stop();
//       _pulseAnimationController.reset();
//     }
//   }

//   @override
//   void dispose() {
//     _scaleAnimationController.dispose();
//     _pulseAnimationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final nodeSize = widget.isActive ? AppConstants.activeNodeSize : AppConstants.nodeSize;
    
//     return Positioned(
//       left: widget.position.dx - (nodeSize * widget.scale) / 2,
//       top: widget.position.dy - (nodeSize * widget.scale) / 2,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: AnimatedBuilder(
//           animation: widget.isActive ? _pulseAnimation : _scaleAnimation,
//           builder: (context, child) {
//             return Transform.scale(
//               scale: widget.isActive ? _pulseAnimation.value * widget.scale : widget.scale,
//               child: GestureDetector(
//                 onTap: widget.onTap,
//                 onLongPress: widget.onDelete,
//                 child: Container(
//                   width: nodeSize,
//                   height: nodeSize,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: widget.isActive ? [
//                         AppConstants.activeNodeColor,
//                         AppConstants.activeNodeColor.withOpacity(0.8),
//                       ] : [
//                         AppConstants.nodeColor,
//                         AppConstants.argentinianBlue2,
//                       ],
//                     ),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: widget.isActive 
//                             ? AppConstants.activeNodeColor.withOpacity(0.4)
//                             : AppConstants.nodeColor.withOpacity(0.3),
//                         blurRadius: widget.isActive ? 15 : 8,
//                         offset: const Offset(0, 4),
//                         spreadRadius: widget.isActive ? 2 : 0,
//                       ),
//                     ],
//                     border: widget.isActive
//                         ? Border.all(
//                             color: Colors.white,
//                             width: 3,
//                           )
//                         : Border.all(
//                             color: AppConstants.frenchBlue.withOpacity(0.3),
//                             width: 1,
//                           ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       widget.node.label,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: widget.isActive ? 20 : 18,
//                         shadows: [
//                           Shadow(
//                             offset: const Offset(1, 1),
//                             blurRadius: 2,
//                             color: Colors.black.withOpacity(0.3),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/tree_node.dart';
import '../utils/constants.dart';

class NodeWidget extends StatefulWidget {
  final TreeNode node;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Offset position;
  final double scale;

  const NodeWidget({
    Key? key,
    required this.node,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
    required this.position,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for node creation
    _scaleAnimationController = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.elasticOut,
    ));

    // Pulse animation for active node
    _pulseAnimationController = AnimationController(
      duration: AppConstants.pulseDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    // Color animation
    _colorAnimation = ColorTween(
      begin: AppConstants.nodeInactiveStart,
      end: AppConstants.activeNodeColor,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimationController.forward();

    if (widget.isActive) {
      _pulseAnimationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulseAnimationController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseAnimationController.stop();
      _pulseAnimationController.reset();
    }
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodeSize =
        widget.isActive ? AppConstants.activeNodeSize : AppConstants.nodeSize;

    return Positioned(
      left: widget.position.dx - (nodeSize * widget.scale) / 2,
      top: widget.position.dy - (nodeSize * widget.scale) / 2,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: widget.isActive ? _pulseAnimation : _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isActive
                  ? _pulseAnimation.value * widget.scale
                  : widget.scale,
              child: GestureDetector(
                onTap: widget.onTap,
                onLongPress: widget.onDelete,
                child: Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isActive
                          ? [
                              AppConstants.activeNodeColor,
                              AppConstants.activeNodeColor.withOpacity(0.7),
                            ]
                          : [
                              AppConstants.nodeInactiveStart,
                              AppConstants.nodeInactiveEnd,
                            ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppConstants.nodeBorder,
                      width:
                          widget.isActive ? 2.5 : AppConstants.borderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isActive
                            ? AppConstants.activeNodeColor.withOpacity(0.6)
                            : Colors.black.withOpacity(0.4),
                        blurRadius: widget.isActive
                            ? AppConstants.glowBlur
                            : 10,
                        spreadRadius: widget.isActive ? 2 : 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.node.label,
                      style: TextStyle(
                        color: AppConstants.nodeTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.isActive ? 20 : 18,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
