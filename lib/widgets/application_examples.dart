import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ApplicationExamples extends StatefulWidget {
  const ApplicationExamples({Key? key}) : super(key: key);

  @override
  State<ApplicationExamples> createState() => _ApplicationExamplesState();
}

class _ApplicationExamplesState extends State<ApplicationExamples> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      height: screenSize.height * (isSmallScreen ? 0.9 : 0.75),
      width: screenSize.width * (isSmallScreen ? 0.9 : 0.65),
      constraints: BoxConstraints(
        maxWidth: isSmallScreen ? double.infinity : 800,
        maxHeight: screenSize.height * 0.9,
        minWidth: 300,
        minHeight: 400,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.nodeInactiveStart,
            AppConstants.darkBackground,
          ],
        ),
        border: Border.all(
          color: AppConstants.activeNodeColor.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25.0,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.darkBackground,
                  AppConstants.nodeInactiveStart,
                ],
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  child: Icon(
                    Icons.apps,
                    color: AppConstants.activeNodeColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutBack,
                    style: const TextStyle(
                      fontFamily: "RobotoMono",
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    child: const Text(
                      'Real-World Applications',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 25,
                    hoverColor: AppConstants.activeNodeColor.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              pageSnapping: true,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: AppExamples.examples.length,
              itemBuilder: (context, index) {
                final example = AppExamples.examples[index];
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0.0;
                    if (_pageController.position.haveDimensions) {
                      value = (_pageController.page ?? 0) - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    } else {
                      value = index == _currentIndex ? 1.0 : 0.0;
                    }
                    
                    return Transform.scale(
                      scale: Curves.easeOut.transform(value * 0.2 + 0.8),
                      child: Opacity(
                        opacity: Curves.easeOut.transform(value * 0.4 + 0.6),
                        child: _buildExampleCard(example),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Page Indicators
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppConstants.darkBackground.withOpacity(0.3),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                Flexible(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: IconButton(
                      onPressed: _currentIndex > 0
                          ? () => _pageController.animateToPage(
                                _currentIndex - 1,
                                duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOutCubic,
                            )
                        : null,
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: _currentIndex > 0 
                            ? AppConstants.activeNodeColor 
                            : Colors.white30,
                      ),
                      splashRadius: 20, // Reduced from 24
                      tooltip: 'Previous',
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Reduced from 20
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      AppExamples.examples.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3), // Reduced from 4
                        width: _currentIndex == index ? 24 : 10, // Reduced sizes
                        height: 10, // Reduced from 12
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: _currentIndex == index
                              ? AppConstants.activeNodeColor
                              : Colors.white30,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Reduced from 20
                Flexible(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: IconButton(
                      onPressed: _currentIndex < AppExamples.examples.length - 1
                          ? () => _pageController.animateToPage(
                                _currentIndex + 1,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOutCubic,
                              )
                          : null,
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: _currentIndex < AppExamples.examples.length - 1 
                            ? AppConstants.activeNodeColor 
                            : Colors.white30,
                      ),
                      splashRadius: 20, // Reduced from 24
                      tooltip: 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(AppExample example) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
        final bool isDesktop = constraints.maxWidth > 500; // Lowered threshold
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(isSmallScreen ? 16 : 25),
          child: SingleChildScrollView(
            child: isDesktop ? _buildDesktopLayout(example, constraints) : _buildMobileLayout(example),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(AppExample example, BoxConstraints constraints) {
    // Desktop Layout: Large image on left, text on right
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Large Image/Icon (45% width for desktop)
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          width: constraints.maxWidth * 0.4, // Reduced from 0.45 to prevent overflow
          height: constraints.maxWidth * 0.3, // Reduced aspect ratio
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.activeNodeColor,
                AppConstants.activeNodeColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppConstants.activeNodeColor.withOpacity(0.3),
                blurRadius: 12.0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: example.imagePath != null && example.imagePath!.isNotEmpty
                ? Image.asset(
                    example.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.account_tree,
                        size: 80,
                        color: Colors.white,
                      );
                    },
                  )
                : const Icon(
                    Icons.account_tree,
                    size: 80,
                    color: Colors.white,
                  ),
          ),
        ),
        const SizedBox(width: 20), // Reduced spacing
        // Right side - Text content
        Expanded(
          child: _buildTextContent(example),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AppExample example) {
    // Mobile Layout: Large centered image at top, title and text below
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Large centered image at top
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          width: 140, // About half the mobile popup width
          height: 140,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.activeNodeColor,
                AppConstants.activeNodeColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppConstants.activeNodeColor.withOpacity(0.3),
                blurRadius: 12.0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: example.imagePath != null && example.imagePath!.isNotEmpty
                ? Image.asset(
                    example.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.account_tree,
                        size: 60,
                        color: Colors.white,
                      );
                    },
                  )
                : const Icon(
                    Icons.account_tree,
                    size: 60,
                    color: Colors.white,
                  ),
          ),
        ),
        
        // Title below image, centered
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          style: const TextStyle(
            fontFamily: "RobotoMono",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
          child: Text(
            example.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Description text below title
        _buildTextContent(example, isMobile: true),
      ],
    );
  }

  Widget _buildTextContent(AppExample example, {bool isMobile = false}) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Title (only for desktop, mobile has it above)
        if (!isMobile) ...[
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            style: const TextStyle(
              fontFamily: "RobotoMono",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            child: Text(example.title),
          ),
          const SizedBox(height: 20),
        ],
        // Description
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          child: Text(
            example.description,
            style: TextStyle(
              fontFamily: "RobotoMono",
              fontSize: isMobile ? 13 : 14,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            maxLines: isMobile ? 3 : 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        // Features Section
        Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppConstants.activeNodeColor,
                  size: isMobile ? 16 : 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Key Features',
                  style: TextStyle(
                    fontFamily: "RobotoMono",
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.activeNodeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Features List - Limited to first 3 features
            ...example.features.take(3).toList().asMap().entries.map((entry) {
              int index = entry.key;
              String feature = entry.value;
              return AnimatedContainer(
                duration: Duration(milliseconds: 500 + (index * 100)),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppConstants.activeNodeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontFamily: "RobotoMono",
                          fontSize: isMobile ? 11 : 12,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        textAlign: isMobile ? TextAlign.center : TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}