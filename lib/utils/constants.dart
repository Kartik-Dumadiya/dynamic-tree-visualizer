import 'package:flutter/material.dart';

class AppConstants {
  // Dark AI Theme Colors
  static const Color darkBackground = Color(0xFF0D1B2A); // deep dark blue
  static const Color nodeInactiveStart = Color(0xFF1B263B); 
  static const Color nodeInactiveEnd = Color(0xFF415A77); 
  static const Color nodeBorder = Colors.white;

  static const Color activeNodeColor = Color(0xFFFF9800); // glowing orange
  static const Color nodeTextColor = Colors.white;

  // Add missing blue color palette (keeping your dark theme intact)
  static const Color aliceBlue = Color(0xFFE3F2FD);
  static const Color uranianBlue = Color(0xFFBBDEFB);
  static const Color lightSkyBlue = Color(0xFF90CAF9);
  static const Color argentinianBlue = Color(0xFF64B5F6);
  static const Color argentinianBlue2 = Color(0xFF42A5F5);
  static const Color dodgerBlue = Color(0xFF2196F3);
  static const Color bleuDeFrance = Color(0xFF1E88E5);
  static const Color frenchBlue = Color(0xFF1976D2);
  static const Color greenBlue = Color(0xFF1565C0);
  static const Color cobaltBlue = Color(0xFF0D47A1);

  // UI Colors (using your dark theme with blue accents)
  static const Color primaryColor = activeNodeColor; // Keep your orange theme
  static const Color nodeColor = argentinianBlue;
  static const Color connectionColor = frenchBlue;
  static const Color backgroundColor = darkBackground; // Your dark background
  static const Color cardColor = Color(0xFF1B263B); // Slightly lighter dark

  // Node Sizing (responsive)
  static const double nodeSize = 60.0;
  static const double activeNodeSize = 75.0;
  static const double mobileNodeSize = 50.0; // Smaller for mobile
  static const double mobileActiveNodeSize = 60.0; // Smaller for mobile
  static const double borderWidth = 1.5;

  // Shadows & Glow
  static const double glowBlur = 20.0;

  // Layout (responsive)
  static const double levelHeight = 160.0; 
  static const double minNodeSpacing = 150.0; 
  static const double mobileLevelHeight = 120.0; // Smaller spacing for mobile
  static const double mobileMinNodeSpacing = 100.0; // Smaller spacing for mobile
  static const double nodeElevation = 8.0;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  
  // Touch targets (for mobile)
  static const double minTouchTarget = 48.0;
  static const double mobilePadding = 16.0;
  static const double desktopPadding = 24.0;

  // Animations
  static const Duration animationDuration = Duration(milliseconds: 400);
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration slowAnimation = Duration(milliseconds: 600);
  static const Duration pulseDuration = Duration(milliseconds: 1000);

  // Zoom (adjusted for mobile)
  static const double minZoom = 0.05;
  static const double maxZoom = 1.0;
  static const double defaultZoom = 0.5;
  static const double mobileDefaultZoom = 0.3; // Smaller default zoom for mobile
  
  // Canvas sizes (responsive)
  static const double canvasWidth = 5000.0;
  static const double canvasHeight = 3500.0;
  static const double mobileCanvasWidth = 3000.0; // Smaller for mobile
  static const double mobileCanvasHeight = 2000.0; // Smaller for mobile
  
  // Helper methods for responsive values
  static double getNodeSize(bool isMobile) => isMobile ? mobileNodeSize : nodeSize;
  static double getActiveNodeSize(bool isMobile) => isMobile ? mobileActiveNodeSize : activeNodeSize;
  static double getLevelHeight(bool isMobile) => isMobile ? mobileLevelHeight : levelHeight;
  static double getMinNodeSpacing(bool isMobile) => isMobile ? mobileMinNodeSpacing : minNodeSpacing;
  static double getDefaultZoom(bool isMobile) => isMobile ? mobileDefaultZoom : defaultZoom;
  static double getPadding(bool isMobile) => isMobile ? mobilePadding : desktopPadding;
  static Size getCanvasSize(bool isMobile) => isMobile 
    ? const Size(mobileCanvasWidth, mobileCanvasHeight) 
    : const Size(canvasWidth, canvasHeight);
}

// Application Examples Data
class AppExample {
  final String title;
  final String description;
  final String imagePath;
  final List<String> features;
  
  const AppExample({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.features,
  });
}

class AppExamples {
  static const List<AppExample> examples = [
    AppExample(
      title: "Organizational Chart",
      description: "Visualize company hierarchy with employees as nodes, showing reporting structures and team organizations.",
      imagePath: "assets/images/org_chart.png",
      features: [
        "Employee hierarchy visualization",
        "Department structure mapping",
        "Reporting relationships",
        "Team organization planning"
      ],
    ),
    AppExample(
      title: "File System Explorer",
      description: "Represent directory structures where folders are parent nodes and files are children.",
      imagePath: "assets/images/file_system.png",
      features: [
        "Directory tree navigation",
        "File organization",
        "Path visualization",
        "Storage structure analysis"
      ],
    ),
    AppExample(
      title: "Mind Mapping Tool",
      description: "Create branching idea structures for brainstorming and knowledge organization.",
      imagePath: "assets/images/mind_map.png",
      features: [
        "Idea brainstorming",
        "Concept relationships",
        "Knowledge mapping",
        "Creative planning"
      ],
    ),
    AppExample(
      title: "Decision Tree AI/ML",
      description: "Visualize machine learning models to understand decision-making processes.",
      imagePath: "assets/images/decision_tree.png",
      features: [
        "ML model visualization",
        "Decision path analysis",
        "Feature importance",
        "Prediction interpretation"
      ],
    ),
    AppExample(
      title: "DOM Tree Structure",
      description: "Represent HTML document structure for web development and debugging.",
      imagePath: "assets/images/dom_tree.png",
      features: [
        "HTML structure visualization",
        "Element hierarchy",
        "CSS selector paths",
        "Web debugging aid"
      ],
    ),
    AppExample(
      title: "Network Topology",
      description: "Map computer network structures showing connections and relationships.",
      imagePath: "assets/images/network_topology.png",
      features: [
        "Network mapping",
        "Connection visualization",
        "Infrastructure planning",
        "Troubleshooting aid"
      ],
    ),
  ];
}
