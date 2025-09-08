import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/tree_node.dart';
import '../utils/constants.dart';

class TreeProvider with ChangeNotifier {
  TreeNode? _root;
  TreeNode? _activeNode;
  int _nodeCounter = 1;
  double _zoomLevel = AppConstants.defaultZoom;
  Offset _panOffset = Offset.zero;
  bool _shouldRecenter = false; // Added flag for recentering
  
  // Getters
  TreeNode? get root => _root;
  TreeNode? get activeNode => _activeNode;
  int get nodeCounter => _nodeCounter;
  double get zoomLevel => _zoomLevel;
  Offset get panOffset => _panOffset;
  bool get shouldRecenter => _shouldRecenter;
  
  // Calculate tree depth
  int get treeDepth {
    if (_root == null) return 0;
    return _calculateDepth(_root!);
  }

  int _calculateDepth(TreeNode node) {
    if (node.children.isEmpty) return 1;
    int maxChildDepth = 0;
    for (TreeNode child in node.children) {
      maxChildDepth = math.max(maxChildDepth, _calculateDepth(child));
    }
    return maxChildDepth + 1;
  }

  TreeProvider() {
    _initializeTree();
  }

  void _initializeTree() {
    _root = TreeNode(
      id: '1',
      label: '1',
    );
    _activeNode = _root;
    _nodeCounter = 2;
    _zoomLevel = AppConstants.defaultZoom;
    _panOffset = Offset.zero;
    _shouldRecenter = true;
    notifyListeners();
  }

  void setActiveNode(TreeNode node) {
    _activeNode = node;
    notifyListeners();
  }

  String? addChildToActiveNode() {
    if (_activeNode == null) return null;

    final newNode = TreeNode(
      id: _nodeCounter.toString(),
      label: _nodeCounter.toString(),
    );

    _activeNode!.addChild(newNode);
    _nodeCounter++;
    _shouldRecenter = true; // Set flag to recenter after adding
    notifyListeners();
    
    return newNode.id; // Return the new node ID
  }

  void deleteNode(TreeNode nodeToDelete) {
    if (nodeToDelete == _root) {
      _initializeTree();
      return;
    }

    if (nodeToDelete.parent != null) {
      if (_activeNode == nodeToDelete || _isNodeInSubtree(_activeNode, nodeToDelete)) {
        _activeNode = nodeToDelete.parent;
      }
      
      nodeToDelete.parent!.removeChild(nodeToDelete);
      _shouldRecenter = true; // Set flag to recenter after deleting
      notifyListeners();
    }
  }

  bool _isNodeInSubtree(TreeNode? node, TreeNode subtreeRoot) {
    if (node == null) return false;
    if (node == subtreeRoot) return true;
    
    for (TreeNode child in subtreeRoot.children) {
      if (_isNodeInSubtree(node, child)) return true;
    }
    return false;
  }

  // Zoom and Pan functionality
  void setZoom(double zoom) {
    _zoomLevel = zoom.clamp(AppConstants.minZoom, AppConstants.maxZoom);
    notifyListeners();
  }

  void zoomIn() {
    setZoom(_zoomLevel * 1.2);
  }

  void zoomOut() {
    setZoom(_zoomLevel * 0.8);
  }

  void resetZoom() {
    _zoomLevel = AppConstants.defaultZoom;
    _panOffset = Offset.zero;
    notifyListeners();
  }

  void setPanOffset(Offset offset) {
    _panOffset = offset;
    notifyListeners();
  }

  void resetTree() {
    _initializeTree();
  }
  
  // Set and reset recenter flag
  void setShouldRecenter(bool value) {
    _shouldRecenter = value;
    notifyListeners();
  }
  
  void resetShouldRecenter() {
    _shouldRecenter = false;
  }
}