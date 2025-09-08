# Dynamic Tree Visualizer

A beautiful Flutter application for creating and visualizing dynamic tree structures with smooth animations and intuitive controls.

## Features ✨

- **Interactive Node Selection**: Tap any node to select it (highlighted in green)
- **Dynamic Node Addition**: Add child nodes to any selected node with smooth animations
- **Node Deletion**: Long press any node to delete it and its entire subtree
- **Smooth Animations**: Elastic animations for node creation and layout transitions
- **Responsive Design**: Works beautifully on mobile, tablet, and desktop
- **Help System**: Built-in instructions for easy onboarding
- **Reset Functionality**: Start fresh with a single tap

## Screenshots 📱

_Add screenshots here once you run the app_

## Getting Started 🚀

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Any IDE with Flutter support (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Kartik-Dumadiya/dynamic-tree-visualizer.git
cd dynamic-tree-visualizer
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## How to Use 📖

1. **Select Node**: Tap any node to select it (turns green)
2. **Add Child**: Use the + button to add a child to the selected node  
3. **Delete Node**: Long press any node to delete it and all its children
4. **Reset**: Use the refresh button to start over
5. **Help**: Tap the help icon for detailed instructions

## Technical Architecture 🏗️

- **State Management**: Provider pattern for efficient state handling
- **Custom Painting**: Canvas API for drawing connections between nodes
- **Animations**: Flutter's animation system with elastic curves
- **Responsive Layout**: LayoutBuilder for adaptive positioning
- **Tree Algorithm**: Level-order traversal for optimal node positioning

## Real-World Applications 🌍

- Organizational charts
- File system visualization  
- Mind mapping tools
- Decision trees in AI/ML
- DOM tree representation
- Network topology mapping

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author 👨‍💻

**Kartik Dumadiya**
- GitHub: [@Kartik-Dumadiya](https://github.com/Kartik-Dumadiya)

## Acknowledgments 🙏

- Flutter team for the amazing framework
- Provider package maintainers
- Flutter community for inspiration
