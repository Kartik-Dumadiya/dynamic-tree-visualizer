import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/tree_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations for mobile
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TreeProvider(),
      child: MaterialApp(
        title: 'Dynamic Tree Visualizer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppConstants.darkBackground,
          primaryColor: AppConstants.activeNodeColor,
          colorScheme: ColorScheme.dark(
            primary: AppConstants.activeNodeColor,
            secondary: AppConstants.nodeInactiveEnd,
            background: AppConstants.darkBackground,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppConstants.darkBackground,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            titleTextStyle: const TextStyle(
              fontFamily: "RobotoMono",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          // Enhanced button themes for responsiveness
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: AppConstants.activeNodeColor,
            foregroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          
          cardTheme: CardThemeData(
            color: AppConstants.nodeInactiveStart,
            elevation: 6,
            shadowColor: AppConstants.activeNodeColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppConstants.nodeBorder, width: 1.0),
            ),
          ),
          
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.activeNodeColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppConstants.activeNodeColor.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(
                fontFamily: "RobotoMono",
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Enhanced text theme for better readability
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: Colors.white, fontFamily: "RobotoMono", fontWeight: FontWeight.bold),
            displayMedium: TextStyle(color: Colors.white, fontFamily: "RobotoMono", fontWeight: FontWeight.w600),
            displaySmall: TextStyle(color: Colors.white, fontFamily: "RobotoMono"),
            headlineLarge: TextStyle(color: Colors.white, fontFamily: "RobotoMono", fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(color: Colors.white, fontFamily: "RobotoMono", fontWeight: FontWeight.w600),
            headlineSmall: TextStyle(color: Colors.white, fontFamily: "RobotoMono"),
            titleLarge: TextStyle(color: Colors.white, fontFamily: "RobotoMono", fontWeight: FontWeight.bold),
            titleMedium: TextStyle(color: Colors.white, fontFamily: "RobotoMono", fontWeight: FontWeight.w500),
            titleSmall: TextStyle(color: Colors.white, fontFamily: "RobotoMono"),
            bodyLarge: TextStyle(color: Colors.white, fontFamily: "RobotoMono"),
            bodyMedium: TextStyle(color: Colors.white70, fontFamily: "RobotoMono"),
            bodySmall: TextStyle(color: Colors.white60, fontFamily: "RobotoMono"),
            labelLarge: TextStyle(color: Colors.white, fontFamily: "RobotoMono", fontWeight: FontWeight.bold),
            labelMedium: TextStyle(color: Colors.white, fontFamily: "RobotoMono"),
            labelSmall: TextStyle(color: Colors.white70, fontFamily: "RobotoMono"),
          ),
          
          // Icon button theme for better touch targets
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(
              foregroundColor: Colors.white70,
              backgroundColor: Colors.transparent,
              minimumSize: const Size(48, 48), // Ensure minimum touch target
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
          ),
        ),
        home: const ResponsiveHomeWrapper(),
      ),
    );
  }
}

// Responsive wrapper to handle different screen sizes and orientations
class ResponsiveHomeWrapper extends StatelessWidget {
  const ResponsiveHomeWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define responsive breakpoints
        final bool isSmallScreen = constraints.maxWidth < 600;
        final bool isMediumScreen = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        final bool isLargeScreen = constraints.maxWidth >= 1024;
        final bool isLandscape = constraints.maxWidth > constraints.maxHeight;
        
        return HomeScreen(
          isSmallScreen: isSmallScreen,
          isMediumScreen: isMediumScreen,
          isLargeScreen: isLargeScreen,
          isLandscape: isLandscape,
          screenWidth: constraints.maxWidth,
          screenHeight: constraints.maxHeight,
        );
      },
    );
  }
}
