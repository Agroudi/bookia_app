import 'dart:ui' as ui;

import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/storage/app_storage.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ultra-premium animated splash screen matching Figma design.
///
/// Features:
/// 1. 3D perspective book cover unfolding along the central spine.
/// 2. Metallic gold sheen sweep across the left cover.
/// 3. Dynamic soft ground shadow expanding with elevation depth.
/// 4. Masked clip & tracking expansion for "Bookia" wordmark.
/// 5. Soft gaussian focus blur reveal for "Order Your Book Now!" tagline.
/// 6. Subtle 3D ambient floating loop.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _shimmerController;
  late final AnimationController _floatController;

  // 1. 3D Page Unfolding
  late final Animation<double> _goldPageAngle;
  late final Animation<double> _darkPageAngle;
  late final Animation<double> _bookElevation;
  late final Animation<double> _bookScale;

  // 2. Gold Sheen Sweep
  late final Animation<double> _shimmerGradientPos;

  // 3. Dynamic Shadow
  late final Animation<double> _shadowScale;
  late final Animation<double> _shadowBlur;
  late final Animation<double> _shadowOpacity;

  // 4. "Bookia" Wordmark Reveal
  late final Animation<double> _titleRevealFraction;
  late final Animation<double> _titleLetterSpacing;
  late final Animation<double> _titleOpacity;

  // 5. "Order Your Book Now!" Tagline Focus Blur Reveal
  late final Animation<double> _taglineBlur;
  late final Animation<double> _taglineOffsetY;
  late final Animation<double> _taglineOpacity;

  // 6. Ambient 3D Float
  late final Animation<double> _ambientFloatY;
  late final Animation<double> _ambientTiltX;

  static const Duration _dwellDuration = Duration(milliseconds: 2900);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _mainController.forward();
    _shimmerController.forward();
    _decideNextRoute();
  }

  void _initAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    // --- Ambient 3D Motion ---
    _ambientFloatY = Tween<double>(begin: 0.0, end: -5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
    _ambientTiltX = Tween<double>(begin: 0.0, end: 0.03).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // --- 1. 3D Book Unfolding ---
    // Left Gold Page swings from +65 degrees to 0 degrees
    _goldPageAngle = Tween<double>(begin: 1.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(
          0.0,
          0.50,
          curve: Cubic(0.175, 0.885, 0.32, 1.15),
        ),
      ),
    );

    // Right Dark Page swings from -75 degrees to 0 degrees
    _darkPageAngle = Tween<double>(begin: -1.30, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(
          0.08,
          0.58,
          curve: Cubic(0.175, 0.885, 0.32, 1.15),
        ),
      ),
    );

    // Book lifts during unfold and settles back
    _bookElevation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -10.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -10.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.60),
      ),
    );

    _bookScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    // --- 2. Metallic Gold Sheen Sweep ---
    _shimmerGradientPos = Tween<double>(begin: -1.2, end: 2.2).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    // --- 3. Dynamic Drop Shadow ---
    _shadowScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _shadowBlur = Tween<double>(begin: 6.0, end: 16.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _shadowOpacity = Tween<double>(begin: 0.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.10, 0.50, curve: Curves.easeIn),
      ),
    );

    // --- 4. "Bookia" Luxury Wordmark Reveal ---
    _titleRevealFraction = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.40, 0.78, curve: Curves.easeOutCubic),
      ),
    );
    _titleLetterSpacing = Tween<double>(begin: 4.0, end: -0.5).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.40, 0.80, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.40, 0.65, curve: Curves.easeIn),
      ),
    );

    // --- 5. Tagline Soft Focus Blur Reveal ---
    _taglineBlur = Tween<double>(begin: 8.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.60, 0.92, curve: Curves.easeOutCubic),
      ),
    );
    _taglineOffsetY = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.60, 0.92, curve: Curves.easeOutCubic),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.60, 0.84, curve: Curves.easeIn),
      ),
    );
  }

  Future<void> _decideNextRoute() async {
    final storage = getIt<SessionStorage>();
    await Future<void>.delayed(_dwellDuration);
    if (!mounted) return;

    final next = switch ((storage.hasSeenOnboarding, storage.isLoggedIn)) {
      (false, _) => Routes.boardingScreen,
      (true, false) => Routes.loginScreen,
      (true, true) => Routes.layoutScreen,
    };

    Navigator.of(context).pushNamedAndRemoveUntil(next, (route) => false);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final matrix =
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_ambientTiltX.value);
            return Transform(
              transform: matrix,
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(0, _ambientFloatY.value),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo Row: 3D Assembling Book Icon + "Bookia" Wordmark
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- 3D Animated Book Icon ---
                  AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bookElevation.value),
                        child: Transform.scale(
                          scale: _bookScale.value,
                          child: SizedBox(
                            width: 60.w,
                            height: 60.w,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Dynamic Drop Shadow
                                Positioned(
                                  bottom: -8.h,
                                  child: Transform.scale(
                                    scale: _shadowScale.value,
                                    child: Opacity(
                                      opacity: _shadowOpacity.value,
                                      child: Container(
                                        width: 50.w,
                                        height: 12.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            25.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.65),
                                              blurRadius: _shadowBlur.value * 1.2,
                                              spreadRadius: 3.r,
                                              offset: const Offset(0, 5),
                                            ),
                                            BoxShadow(
                                              color: const Color(
                                                0xFFD4AF37,
                                              ).withValues(alpha: 0.35),
                                              blurRadius: _shadowBlur.value * 1.8,
                                              spreadRadius: 6.r,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Book Spine Center Pivot Box
                                SizedBox(
                                  width: 60.w,
                                  height: 60.w,
                                  child: Stack(
                                    children: [
                                      // --- Left Gold Page (Flips on Right Spine Edge) ---
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        bottom: 0,
                                        width: 60.w,
                                        child: Transform(
                                          alignment: Alignment.centerRight,
                                          transform:
                                              Matrix4.identity()
                                                ..setEntry(3, 2, 0.002)
                                                ..rotateY(_goldPageAngle.value),
                                          child: Stack(
                                            children: [
                                              // Gold Base Cover with Specular Metallic Shimmer Sweep
                                              ShaderMask(
                                                shaderCallback: (bounds) {
                                                  final pos =
                                                      _shimmerGradientPos.value;
                                                  return LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: const [
                                                      Color(0xFFBFA054),
                                                      Color(0xFFFFF0C4),
                                                      Color(0xFFBFA054),
                                                    ],
                                                    stops: [
                                                      (pos - 0.3).clamp(
                                                        0.0,
                                                        1.0,
                                                      ),
                                                      pos.clamp(0.0, 1.0),
                                                      (pos + 0.3).clamp(
                                                        0.0,
                                                        1.0,
                                                      ),
                                                    ],
                                                  ).createShader(bounds);
                                                },
                                                blendMode: BlendMode.srcATop,
                                                child: SvgPicture.asset(
                                                  'assets/icons/splash_gold_page.svg',
                                                  width: 60.w,
                                                  height: 60.w,
                                                ),
                                              ),
                                              // Distinct Crisp Black Markings Overlay
                                              SvgPicture.asset(
                                                'assets/icons/splash_gold_dashes.svg',
                                                width: 60.w,
                                                height: 60.w,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // --- Right Dark Page (Flips on Left Spine Edge) ---
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        bottom: 0,
                                        width: 60.w,
                                        child: Transform(
                                          alignment: Alignment.centerLeft,
                                          transform:
                                              Matrix4.identity()
                                                ..setEntry(3, 2, 0.002)
                                                ..rotateY(_darkPageAngle.value),
                                          child: SvgPicture.asset(
                                            'assets/icons/splash_dark_page.svg',
                                            width: 60.w,
                                            height: 60.w,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(width: 14.w),

                  // --- "Bookia" Luxury Wordmark Reveal ---
                  AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      final fraction = _titleRevealFraction.value;
                      return Opacity(
                        opacity: _titleOpacity.value,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: fraction.clamp(0.001, 1.0),
                          child: ClipRect(
                            child: Text(
                              'Bookia',
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: AppTextStyle.headlineLarge.copyWith(
                                fontFamily: AppFonts.display,
                                fontSize: 42.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.dark,
                                letterSpacing: _titleLetterSpacing.value,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 18.h),

              // --- "Order Your Book Now!" Tagline Soft Focus Blur Reveal ---
              AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  final blurVal = _taglineBlur.value;
                  return Transform.translate(
                    offset: Offset(0, _taglineOffsetY.value),
                    child: Opacity(
                      opacity: _taglineOpacity.value,
                      child:
                          blurVal > 0.1
                              ? ImageFiltered(
                                imageFilter: ui.ImageFilter.blur(
                                  sigmaX: blurVal,
                                  sigmaY: blurVal,
                                ),
                                child: child,
                              )
                              : child,
                    ),
                  );
                },
                child: Text(
                  'Order Your Book Now!',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.subtitle.copyWith(
                    fontFamily: AppFonts.display,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.dark,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
