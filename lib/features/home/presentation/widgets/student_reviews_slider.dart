import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class StudentReviewsSlider extends StatefulWidget {
  const StudentReviewsSlider({super.key});

  @override
  State<StudentReviewsSlider> createState() => _StudentReviewsSliderState();
}

class _StudentReviewsSliderState extends State<StudentReviewsSlider> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;
  bool _isAutoPlaying = true;

  // Real review image assets list from assets/reviews/
  static const List<String> _reviewAssets = [
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.28 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.28 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.30 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.31 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.31 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.32 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.33 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.33 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.34 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.36 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.36 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.37 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.37 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.38 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.38 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.39 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.39 PM (2).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.39 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.40 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.40 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.41 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.42 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.42 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.43 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.43 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.44 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.44 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.45 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.46 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.46 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.47 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.48 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.49 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.49 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.50 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.50 PM (2).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.50 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.51 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.51 PM (2).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.51 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.52 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.52 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.54 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.55 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.56 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.56 PM (2).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.56 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.57 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.57 PM (2).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.57 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.58 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.58 PM (2).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.58 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.59 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.17.59 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.14 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.15 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.16 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.16 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.18 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.18 PM (2).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.18 PM (3).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.18 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.19 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.19 PM (2).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.19 PM (3).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.19 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.20 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.20 PM (2).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.20 PM (3).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.20 PM.jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.21 PM (1).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.21 PM (2).jpeg',
    'assets/reviews/WhatsApp Image 2026-07-17 at 5.22.21 PM (3).jpeg',
  ];

  List<String> _getStudentTitles(BuildContext context) {
    return [
      context.translate('student_title_1'),
      context.translate('student_title_2'),
      context.translate('student_title_3'),
      context.translate('student_title_4'),
      context.translate('student_title_5'),
      context.translate('student_title_6'),
    ];
  }

  // ─── Enhanced Lightbox with Zoom Controls and Swipe Navigation ─────────────
  void _showImageLightbox(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (ctx) {
        return _LightboxDialog(
          images: _reviewAssets,
          initialIndex: initialIndex,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final studentTitles = _getStudentTitles(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Section Header Badge ────────────────────────────────────────────────
        FadeInDown(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Color(0xFF25D366),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.translate('our_students_opinions'),
                      style: GoogleFonts.cairo(
                        fontSize: isTablet ? 15 : 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.translate('reviews_section_title'),
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: isTablet ? 28 : 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  context.translate('reviews_section_subtitle'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: isTablet ? 14 : 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Carousel Slider ──────────────────────────────────────────────────────
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: _reviewAssets.length,
          options: CarouselOptions(
            // ✅ ارتفاع مناسب جداً لعرض الصورة كاملة بدون قطع
            height: isTablet ? 650 : 580,
            autoPlay: _isAutoPlaying,
            enlargeCenterPage: true,
            enlargeFactor: 0.22,
            viewportFraction: isTablet ? 0.48 : 0.88,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final imagePath = _reviewAssets[index];
            final titleStr = studentTitles[index % studentTitles.length];

            return Builder(
              builder: (BuildContext context) {
                return InkWell(
                  onTap: () => _showImageLightbox(context, index),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: index == _currentIndex
                            ? AppColors.primaryBlue.withValues(alpha: 0.4)
                            : AppColors.border.withValues(alpha: 0.6),
                        width: index == _currentIndex ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: index == _currentIndex
                              ? AppColors.primaryBlue.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.04),
                          blurRadius: index == _currentIndex ? 20 : 10,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ── Comment Header ────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight
                                .withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24)),
                            border: Border(
                              bottom: BorderSide(
                                  color:
                                      AppColors.border.withValues(alpha: 0.4)),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Avatar / Badge
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            titleStr,
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: Color(0xFF25D366),
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (starIndex) => const Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFFFFB800),
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Zoom hint icon
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.zoom_in_rounded,
                                  color: AppColors.primaryBlue,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Image Feedback Content ─────────────────────
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(
                                    color: const Color(0xFFF8FAFC),
                                    child: Image.asset(
                                      imagePath,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                      filterQuality: FilterQuality.high,
                                      isAntiAlias: true,
                                      gaplessPlayback: true,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        final fallbackPath = imagePath
                                            .replaceAll('assets/reviews/',
                                                'assets/images/reviews/');
                                        return Image.asset(
                                          fallbackPath,
                                          fit: BoxFit.contain,
                                          alignment: Alignment.center,
                                          filterQuality: FilterQuality.high,
                                          isAntiAlias: true,
                                          gaplessPlayback: true,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: AppColors.backgroundLight,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                    Icons
                                                        .image_not_supported_rounded,
                                                    size: 40,
                                                    color: AppColors
                                                        .textSecondary),
                                                const SizedBox(height: 8),
                                                Text(
                                                  context.translate(
                                                      'image_not_available'),
                                                  style: GoogleFonts.cairo(
                                                      color: AppColors
                                                          .textSecondary,
                                                      fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Gradient Overlay Hint
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black
                                                .withValues(alpha: 0.75),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.touch_app_rounded,
                                              color: Colors.white, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            context.translate('tap_to_zoom_hint'),
                                            style: GoogleFonts.cairo(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),

        const SizedBox(height: 16),

        // ── Controls & Counter ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous Button
              IconButton(
                onPressed: () => _carouselController.previousPage(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: AppColors.textPrimary),
                ),
              ),

              const SizedBox(width: 12),

              // Page Counter Indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${_reviewAssets.length}',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // AutoPlay Toggle Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isAutoPlaying = !_isAutoPlaying;
                  });
                },
                tooltip: context.translate(
                    _isAutoPlaying ? 'pause_autoplay' : 'start_autoplay'),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isAutoPlaying
                        ? AppColors.primaryBlue.withValues(alpha: 0.1)
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    _isAutoPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Next Button
              IconButton(
                onPressed: () => _carouselController.nextPage(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stateful Lightbox Dialog with Zoom & Navigation ───────────────────────
class _LightboxDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _LightboxDialog({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_LightboxDialog> createState() => _LightboxDialogState();
}

class _LightboxDialogState extends State<_LightboxDialog> {
  late int _currentIndex;
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else if (_doubleTapDetails != null) {
      final position = _doubleTapDetails!.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translateByDouble(-position.dx * 1.5, -position.dy * 1.5, 0.0, 1.0)
        ..scaleByDouble(2.5, 2.5, 1.0, 1.0);
    }
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * 1.5).clamp(0.5, 10.0);
    _transformationController.value = Matrix4.diagonal3Values(newScale, newScale, 1.0);
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.5).clamp(0.5, 10.0);
    _transformationController.value = Matrix4.diagonal3Values(newScale, newScale, 1.0);
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final currentImagePath = widget.images[_currentIndex];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(6),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Main Image View with Pinch and Double-Tap Zoom ───────────────
          GestureDetector(
            onDoubleTapDown: (details) => _doubleTapDetails = details,
            onDoubleTap: _handleDoubleTap,
            child: Center(
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 10.0,
                panEnabled: true,
                scaleEnabled: true,
                clipBehavior: Clip.none,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width * 0.98,
                    maxHeight: screenSize.height * 0.90,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      currentImagePath,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset(
                        currentImagePath.replaceAll(
                            'assets/reviews/', 'assets/images/reviews/'),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        isAntiAlias: true,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Close Button (Top Right) ──────────────────────────────────────
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ),

          // ── Navigation Arrow Left ─────────────────────────────────────────
          if (_currentIndex > 0)
            Positioned(
              left: 8,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex--;
                    _resetZoom();
                  });
                },
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),

          // ── Navigation Arrow Right ────────────────────────────────────────
          if (_currentIndex < widget.images.length - 1)
            Positioned(
              right: 8,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex++;
                    _resetZoom();
                  });
                },
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),

          // ── Bottom Control Toolbar (Zoom buttons & Counter) ──────────────
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom In Button
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _zoomIn,
                      icon: const Icon(Icons.zoom_in_rounded,
                          color: Colors.white, size: 20),
                      tooltip: 'تكبير',
                    ),
                    // Zoom Out Button
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _zoomOut,
                      icon: const Icon(Icons.zoom_out_rounded,
                          color: Colors.white, size: 20),
                      tooltip: 'تصغير',
                    ),
                    // Reset Zoom Button
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _resetZoom,
                      icon: const Icon(Icons.restart_alt_rounded,
                          color: Colors.white, size: 18),
                      tooltip: 'إعادة الضبط',
                    ),
                    const SizedBox(width: 8),
                    Container(height: 16, width: 1, color: Colors.white30),
                    const SizedBox(width: 8),
                    Text(
                      context.translate('lightbox_quality_hint'),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${_currentIndex + 1}/${widget.images.length})',
                      style: GoogleFonts.cairo(
                        color: AppColors.primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
