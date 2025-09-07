import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tree_provider.dart';
import '../widgets/tree_visualizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dynamic Tree Visualizer 🌳'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showInstructions(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TreeProvider>().resetTree();
            },
          ),
        ],
      ),
      body: const TreeVisualizer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<TreeProvider>().addChildToActiveNode();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to Use 📖'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎯 Select Node:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Tap any node to select it (it will turn green)'),
                SizedBox(height: 12),
                Text('➕ Add Child:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Use the + button to add a child to the selected node'),
                SizedBox(height: 12),
                Text('🗑️ Delete Node:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Long press any node to delete it and all its children'),
                SizedBox(height: 12),
                Text('🔄 Reset:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Use the refresh button to start over'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }
}