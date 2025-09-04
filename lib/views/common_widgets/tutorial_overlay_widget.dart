import 'dart:ui';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// App color palette
const Color bgStart = Color(0xFF070B14);
const Color bgEnd = Color(0xFF0E1624);
const Color primaryA = Color(0xFF3D4DFF);
const Color primaryB = Color(0xFF29C0FF);
const Color panelTop = Color(0xFF0F1724);
const Color panelBottom = Color(0xFF111827);
const Color mutedText = Color(0xFF9AA8BF);

class TutorialOverlay {
  static void showTutorial(BuildContext context, {
    required GlobalKey swipeRightKey,
    required GlobalKey swipeUpKey,
    required GlobalKey chatbotKey,
    required GlobalKey headlineKey,
    required VoidCallback onFinish,
  }) {
    List<TargetFocus> targets = [];

    // Target 1: Swipe up for more news
    targets.add(
      TargetFocus(
        identify: "swipe_up",
        keyTarget: swipeUpKey,
        alignSkip: Alignment.topCenter,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: MediaQuery.of(context).size.height * 0.15,
            ),
            builder: (context, controller) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [panelTop, panelBottom],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryA.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryA, primaryB],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.swipe_up,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Swipe Up for More News",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Swipe up to scroll through more news articles and stay updated.",
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 15,
      ),
    );

// Target 2: Swipe right for dashboard
    targets.add(
      TargetFocus(
        identify: "swipe_right",
        keyTarget: swipeRightKey,
        alignSkip: Alignment.bottomCenter,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: MediaQuery.of(context).size.height * 0.1,
            ),
            builder: (context, controller) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [panelTop, panelBottom],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryA.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.swipe_right,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Swipe Right for Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Swipe right to access categories, bookmarks, and settings.",
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 15,
      ),
    );

    // Target 3: News Headline for bookmarking
    targets.add(
      TargetFocus(
        identify: "headline_bookmark",
        keyTarget: headlineKey,
        alignSkip: Alignment.topCenter,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [panelTop, panelBottom],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryA.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bookmark_add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Tap to Bookmark",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap on any news headline to bookmark it for later reading.",
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 8,
      ),
    );

    // Target 4: Chatbot button
    targets.add(
      TargetFocus(
        identify: "chatbot",
        keyTarget: chatbotKey,
        alignSkip: Alignment.topCenter,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [panelTop, panelBottom],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryA.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF10B981), Color(0xFF34D399)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "AI Chat Assistant",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap the chatbot to start a conversation about this news article.",
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.Circle,
        radius: 30,
      ),
    );

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.85,
      hideSkip: false,
      useSafeArea: true,
      onFinish: () {
        onFinish();
      },
      onClickTarget: (target) {
        // Allow target clicks to pass through
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        // Allow positioned clicks to pass through
      },
      onClickOverlay: (target) {
        // Allow overlay clicks to continue tutorial
      },
      onSkip: () {
        print("Skip button pressed!");
        onFinish();
        return true;
      },
    ).show(context: context);
  }
}
