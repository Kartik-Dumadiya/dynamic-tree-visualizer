class TreeNode {
  final String id;
  final String label;
  final List<TreeNode> children;
  TreeNode? parent;

  TreeNode({
    required this.id,
    required this.label,
    this.parent,
    List<TreeNode>? children,
  }) : children = children ?? [];

  void addChild(TreeNode child) {
    child.parent = this;
    children.add(child);
  }

  void removeChild(TreeNode child) {
    children.remove(child);
    child.parent = null;
  }

  TreeNode? findNodeById(String id) {
    if (this.id == id) return this;
    
    for (TreeNode child in children) {
      TreeNode? found = child.findNodeById(id);
      if (found != null) return found;
    }
    return null;
  }

  List<TreeNode> getAllNodes() {
    List<TreeNode> nodes = [this];
    for (TreeNode child in children) {
      nodes.addAll(child.getAllNodes());
    }
    return nodes;
  }

  @override
  String toString() => 'TreeNode(id: $id, label: $label)';
}