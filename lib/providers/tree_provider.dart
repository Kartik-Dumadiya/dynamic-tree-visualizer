import 'package:flutter/foundation.dart';
import '../models/tree_node.dart';

class TreeProvider with ChangeNotifier {
  TreeNode? _root;
  TreeNode? _activeNode;
  int _nodeCounter = 1;

  TreeNode? get root => _root;
  TreeNode? get activeNode => _activeNode;
  int get nodeCounter => _nodeCounter;

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
    notifyListeners();
  }

  void setActiveNode(TreeNode node) {
    _activeNode = node;
    notifyListeners();
  }

  void addChildToActiveNode() {
    if (_activeNode == null) return;

    final newNode = TreeNode(
      id: _nodeCounter.toString(),
      label: _nodeCounter.toString(),
    );

    _activeNode!.addChild(newNode);
    _nodeCounter++;
    notifyListeners();
  }

  void deleteNode(TreeNode nodeToDelete) {
    if (nodeToDelete == _root) {
      // Don't allow deleting root, or reinitialize
      _initializeTree();
      return;
    }

    if (nodeToDelete.parent != null) {
      // If deleting active node, set parent as active
      if (_activeNode == nodeToDelete || _isNodeInSubtree(_activeNode, nodeToDelete)) {
        _activeNode = nodeToDelete.parent;
      }
      
      nodeToDelete.parent!.removeChild(nodeToDelete);
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

  void resetTree() {
    _initializeTree();
  }
}