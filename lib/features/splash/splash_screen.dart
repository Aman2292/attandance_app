import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _cursorController;
  late Animation<double> _logoOpacity;
  late Animation<int> _typingAnimation;
  late Animation<double> _cursorOpacity;

  final String _fullText = "Unsquare Attendance Management System";
  String _currentText = "";
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text typing animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 3000), // Increased duration for longer text
      vsync: this,
    );

    // Cursor blinking animation controller
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Logo opacity animation
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Typing animation
    _typingAnimation = IntTween(
      begin: 0,
      end: _fullText.length,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    // Cursor blinking animation
    _cursorOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeInOut,
    ));

    // Listen to typing animation
    _typingAnimation.addListener(() {
      setState(() {
        _currentText = _fullText.substring(0, _typingAnimation.value);
      });
    });

    // Listen to animation completion
    _textController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Stop cursor blinking and navigate after delay
        Future.delayed(const Duration(milliseconds: 800), () {
          _cursorController.stop();
          setState(() {
            _showCursor = false;
          });
          
          // Navigate to login screen
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.go('/login');
            }
          });
        });
      }
    });
  }

  void _startAnimationSequence() {
    // Start logo animation
    _logoController.forward();

    // Start cursor blinking
    _cursorController.repeat(reverse: true);

    // Start typing animation after logo animation
    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });
  }

  Widget _buildTypingText() {
    // Split the current text to handle "Unsquare" differently
    if (_currentText.isEmpty) return const SizedBox();
    
    String displayText = _currentText;
    bool showingUnsquare = displayText.length <= 8; // "Unsquare" is 8 characters
    
    if (showingUnsquare) {
      // Currently typing "Unsquare"
      String unPart = "";
      String squarePart = "";
      
      if (displayText.length <= 2) {
        unPart = displayText; // "U" or "Un"
      } else {
        unPart = "Un";
        squarePart = displayText.substring(2); // "s", "sq", "squ", etc.
      }
      
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            if (unPart.isNotEmpty)
              TextSpan(
                text: unPart,
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 20,
                    ),
                    Shadow(
                      color: AppColors.primary.withOpacity(0.6),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
            if (squarePart.isNotEmpty)
              TextSpan(
                text: squarePart,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: -1,
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 20,
                    ),
                    Shadow(
                      color: AppColors.primary.withOpacity(0.6),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    } else {
      // Showing "Unsquare" + additional text
      String remainingText = displayText.substring(8); // Everything after "Unsquare"
      
      return Column(
        children: [
          // Unsquare part (complete)
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Un',
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 20,
                      ),
                      Shadow(
                        color: AppColors.primary.withOpacity(0.6),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
                TextSpan(
                  text: 'square',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: -1,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 20,
                      ),
                      Shadow(
                        color: AppColors.primary.withOpacity(0.6),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Additional text
          Text(
            remainingText,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.6),
                  blurRadius: 15,
                ),
                Shadow(
                  color: AppColors.accent.withOpacity(0.4),
                  blurRadius: 25,
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 90), // Add some top spacing
            
            // Typing Text Section
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Container(
                    height: 130,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: AnimatedBuilder(
                            animation: _textController,
                            builder: (context, child) {
                              return _buildTypingText();
                            },
                          ),
                        ),
                        // Animated cursor
                        if (_showCursor)
                          AnimatedBuilder(
                            animation: _cursorController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _cursorOpacity.value,
                                child: Container(
                                  width: 3,
                                  height: 28,
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.6),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 80),
            
            // Loading indicator with different gradient
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            
           
            
            // Loading text
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Text(
                    'Initializing...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
