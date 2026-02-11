import 'package:cofit_collective/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: Stack(
        children: [
          // Background gradient

          // Decorative floating shapes
          ..._buildFloatingShapes(context),

          // Main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo container with glow
                  Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.4),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset('assets/icons/app_logo.png'),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                        duration: 1000.ms,
                      ),

                  const SizedBox(height: 40),

                  // App Name with style
                  ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF6B6B)],
                        ).createShader(bounds),
                        child: Text(
                          'CoFit',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: Color(0xFFFF6B6B),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),

                  Text(
                        'COLLECTIVE',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.black.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 8,
                            ),
                      )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(begin: 0.5, end: 0),

                  const SizedBox(height: 16),

                  // Tagline
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B6B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Stronger Together',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Color(0xFFFF6B6B),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 500.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                      ),

                  const Spacer(flex: 2),

                  // Loading section
                  Column(
                    children: [
                      // Animated dots loader
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: List.generate(3, (index) {
                      //     return Container(
                      //           margin: const EdgeInsets.symmetric(
                      //             horizontal: 4,
                      //           ),
                      //           width: 10,
                      //           height: 10,
                      //           decoration: BoxDecoration(
                      //             color: Colors.pink.withValues(alpha: 0.8),
                      //             shape: BoxShape.circle,
                      //           ),
                      //         )
                      //         .animate(
                      //           onPlay: (controller) => controller.repeat(),
                      //         )
                      //         .fadeIn(delay: (1000 + index * 200).ms)
                      //         .then()
                      //         .scale(
                      //           begin: const Offset(1, 1),
                      //           end: const Offset(1.3, 1.3),
                      //           duration: 600.ms,
                      //           delay: (index * 200).ms,
                      //         )
                      //         .then()
                      //         .scale(
                      //           begin: const Offset(1.3, 1.3),
                      //           end: const Offset(1, 1),
                      //           duration: 600.ms,
                      //         );
                      //   }),
                      // ),
                      const SizedBox(height: 20),
                      Text(
                        'Your fitness journey starts here',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black),
                      ).animate().fadeIn(delay: 1200.ms, duration: 500.ms),
                    ],
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingShapes(BuildContext context) {
    return [
      // Top left circle
      Positioned(
        top: -50,
        left: -50,
        child:
            Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pink.withValues(alpha: 0.1),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: 0,
                  end: 20,
                  duration: 3000.ms,
                  curve: Curves.easeInOut,
                ),
      ),

      // Top right blob
      Positioned(
        top: 100,
        right: -30,
        child:
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pink.withValues(alpha: 0.08),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(
                  begin: 0,
                  end: -15,
                  duration: 2500.ms,
                  curve: Curves.easeInOut,
                ),
      ),

      // Bottom left shape
      Positioned(
        bottom: 150,
        left: -40,
        child:
            Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pink.withValues(alpha: 0.06),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: 0,
                  end: -25,
                  duration: 3500.ms,
                  curve: Curves.easeInOut,
                ),
      ),

      // Bottom right shape
      Positioned(
        bottom: -60,
        right: 50,
        child:
            Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pink.withValues(alpha: 0.1),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(
                  begin: 0,
                  end: 20,
                  duration: 4000.ms,
                  curve: Curves.easeInOut,
                ),
      ),

      // Small floating hearts
      Positioned(
        top: MediaQuery.of(context).size.height * 0.25,
        left: 40,
        child:
            Icon(
                  Iconsax.heart5,
                  size: 25,
                  color: Colors.pink.withValues(alpha: 0.3),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -15, duration: 2000.ms)
                .fadeIn(delay: 500.ms),
      ),

      Positioned(
        top: MediaQuery.of(context).size.height * 0.35,
        right: 50,
        child:
            Icon(
                  Iconsax.star5,
                  size: 22,
                  color: Colors.pink.withValues(alpha: 0.25),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: 10, duration: 1800.ms)
                .fadeIn(delay: 700.ms),
      ),

      Positioned(
        bottom: MediaQuery.of(context).size.height * 0.3,
        right: 30,
        child:
            Icon(
                  Iconsax.flash_15,
                  size: 22,
                  color: Colors.pink.withValues(alpha: 0.2),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: -10, duration: 2200.ms)
                .fadeIn(delay: 900.ms),
      ),
    ];
  }
}
