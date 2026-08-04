import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:herr_khaled/core/di/service_locator.dart';
import 'package:herr_khaled/core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/data/repos/auth_repo.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../widgets/home_drawer.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../admin/presentation/cubit/admin_cubit.dart';
import '../../../admin/presentation/cubit/admin_state.dart';
import '../widgets/local_video_player.dart';
import '../widgets/student_reviews_slider.dart';
import '../widgets/student_progress_widget.dart';
import '../../../../core/widgets/developer_contact_dialog.dart';
import '../../../../core/widgets/welcome_greeting_dialog.dart';
import '../../../../core/services/app_settings_service.dart';
import '../widgets/branches_map_widget.dart';
import '../widgets/herr_khaled_spiral_hero.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _coursesSectionKey = GlobalKey();
  int _currentPage = 0;
  bool _isLoadingCourses = true;
  Timer? _sliderTimer;

  final List<Map<String, String>> _sliderItems = [
    {
      'title': 'slider_title_1',
      'subtitle': 'slider_subtitle_1',
      'image': 'assets/images/slider1.png',
    },
    {
      'title': 'slider_title_2',
      'subtitle': 'slider_subtitle_2',
      'image': 'assets/images/slider2.png',
    },
    {
      'title': 'slider_title_3',
      'subtitle': 'slider_subtitle_3',
      'image': 'assets/images/slider3.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Show premium welcome greeting dialog on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          WelcomeGreetingDialog.show(context);
        }
      });
    });

    // Simulate loading data
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoadingCourses = false;
        });
      }
    });

    // Auto-scroll slider like an ad banner 🎯
    _startSliderAutoScroll();
  }

  void _startSliderAutoScroll() {
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _sliderItems.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: FadeIn(
        duration: const Duration(milliseconds: 1000),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _buildAnnouncementAndLiveBanners(context),
              const StudentProgressWidget(),
              _buildSearchBar(context),
              const HerrKhaledSpiralHero(),
              const SizedBox(height: 10),
              _buildHeroSlider(context),
              const SizedBox(height: 40),
              _buildFeaturesSection(),
              const SizedBox(height: 40),
              _buildInstructorIntro(context),
              const SizedBox(height: 40),
              // ─── Book Teaser Section ─────────────────────────
              _buildBookTeaser(context),
              const SizedBox(height: 40),
              Container(
                key: _coursesSectionKey,
                child: _buildCoursesSection(context),
              ),
              const SizedBox(height: 50),
              _buildTestimonialsSection(),
              const SizedBox(height: 50),
              _buildReviewVideoSection(),
              const SizedBox(height: 30),
              const BranchesMapWidget(),
              const SizedBox(height: 10),
              _buildFAQSection(),
              const SizedBox(height: 60),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color itemColor = isDark ? Colors.white : AppColors.primaryBlue;

    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: itemColor, size: 36),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(right: 8, left: 4),
        child: Row(
          children: [
            Text(
              'Deutsch Welt',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
                fontSize: 18,
              ),
            ),

            const Spacer(),

            // Right Action Controls (Auth Only) wrapped in FittedBox to guarantee zero overflow
            Flexible(
              fit: FlexFit.loose,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Auth Section (Greeting or Login/SignUp)
                    FutureBuilder<String?>(
                      future: Future.value(sl<StorageService>().user),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final userData = jsonDecode(snapshot.data!);
                          final firstName = userData['first_name'] ?? '';
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${context.translate('hello')} $firstName 👋',
                                style: GoogleFonts.cairo(
                                  color: itemColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFF1F5F9),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 32,
                                  color: itemColor,
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRoutes.login),
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                context.translate('login'),
                                style: GoogleFonts.cairo(
                                  color: itemColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                elevation: 3,
                                minimumSize: const Size(125, 52),
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRoutes.signUp),
                              child: Text(
                                context.translate('signup'),
                                style: GoogleFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementAndLiveBanners(BuildContext context) {
    return FutureBuilder<AppSettingsModel>(
      future: AppSettingsService.loadSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final settings = snapshot.data!;

        return Column(
          children: [
            // Live YouTube Broadcast Bar
            if (settings.isLiveActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.redAccent,
                child: Row(
                  children: [
                    const Icon(Icons.live_tv_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'بث مباشر الآن على يوتيوب مع Herr خالد الحلواني! 🔴',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _launchUrl(settings.youtubeLiveUrl),
                      child: Text(
                        'انضم للبث 🎥',
                        style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // Announcement Banner - Ultra Premium Floating Card Design
            if (settings.isAnnouncementActive && settings.announcementText.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F172A), // Deep Midnight
                      Color(0xFF1E3A8A), // Royal Indigo
                      Color(0xFF0D9488), // Emerald Cyan Tint
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Glowing Badge Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFFBBF24),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (settings.discountPercentage.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBBF24),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🏷️ خصم خاص ${settings.discountPercentage}',
                                style: GoogleFonts.cairo(
                                  color: const Color(0xFF0F172A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          Text(
                            settings.announcementText,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.levels),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          'اشترك 🚀',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            Navigator.pushNamed(context, AppRoutes.levels);
          }
        },
        decoration: InputDecoration(
          hintText: isDark ? 'Suche nach Kursen...' : 'ابحث عن كورس أو مرحلة أو درس...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSlider(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Container(
        height: 480, // Increased height to prevent bottom overflow
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _sliderItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Placeholder for image
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Image.asset(
                              'assets/images/deutsch_welt.jpeg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        context.translate(_sliderItems[index]['title']!),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineMedium?.color ?? AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.translate(_sliderItems[index]['subtitle']!),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _sliderItems.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryBlue
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 20),
              child: Text(
                context.translate('why_academy'),
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.published_with_changes_rounded,
                    title: 'daily_followup',
                    subtitleKey: 'direct_mentor',
                    color: AppColors.primaryBlue,
                    type: 'lectures',
                    delay: 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.workspace_premium_rounded,
                    title: 'exam_preparation',
                    subtitleKey: 'high_success',
                    color: AppColors.primaryBlue,
                    type: 'exams',
                    delay: 200,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.support_agent_rounded,
                    title: 'technical_support',
                    subtitleKey: 'always_available',
                    color: AppColors.primaryBlue,
                    type: 'support',
                    isSupport: true,
                    delay: 400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitleKey,
    required Color color,
    required String type,
    required int delay,
    bool isSupport = false,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isSupport) {
              _showFeatureDetailModal(
                icon: icon,
                titleKey: title,
                descKey: 'tech_support_desc',
                btnKey: 'contact_whatsapp_now',
                onBtnPressed: () => _launchWhatsApp('01055287454'),
              );
              return;
            }
            if (type == 'lectures') {
              _showFeatureDetailModal(
                icon: icon,
                titleKey: title,
                descKey: 'daily_followup_desc',
                btnKey: 'explore_courses',
                onBtnPressed: () => Navigator.pushNamed(context, AppRoutes.levels),
              );
              return;
            }
            if (type == 'exams') {
              _showFeatureDetailModal(
                icon: icon,
                titleKey: title,
                descKey: 'exam_prep_desc',
                btnKey: 'explore_books',
                onBtnPressed: () => Navigator.pushNamed(context, AppRoutes.book),
              );
              return;
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.18),
                        color.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 44, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  context.translate(title),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.titleMedium?.color ?? AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.translate(subtitleKey),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeatureDetailModal({
    required IconData icon,
    required String titleKey,
    required String descKey,
    required String btnKey,
    required VoidCallback onBtnPressed,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                context.translate(titleKey).replaceAll('\n', ' '),
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.translate(descKey),
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  onBtnPressed();
                },
                child: Text(
                  context.translate(btnKey),
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoursesSection(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInLeft(
            child: Text(
              context.translate('available_courses'),
              style: GoogleFonts.cairo(
                fontSize: isTablet ? 30 : 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _isLoadingCourses
              ? CustomShimmer.list(
                  count: 3,
                  height: 120,
                  padding: EdgeInsets.zero,
                )
              : FutureBuilder<AppSettingsModel>(
                  future: AppSettingsService.loadSettings(),
                  builder: (context, snapshot) {
                    final settings = snapshot.data ?? AppSettingsModel.defaultSettings();
                    final prices = [settings.priceA1, settings.priceA2, settings.priceB1, settings.priceB2];

                    return FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: isTablet
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: screenWidth >= 900 ? 3 : 2,
                                childAspectRatio: screenWidth >= 900 ? 2.5 : 2.6,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                final levels = ['A1', 'A2', 'B1', 'B2'];
                                return _buildCourseCard(
                                  context,
                                  title: '${context.translate('course_level')} ${levels[index]}',
                                  price: '${prices[index]} ${context.translate('currency')}',
                                  lessons: '24 ${context.translate('lessons_count')}',
                                  duration: '8 ${context.translate('weeks_count')}',
                                );
                              },
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                final levels = ['A1', 'A2', 'B1', 'B2'];
                                return _buildCourseCard(
                                  context,
                                  title: '${context.translate('course_level')} ${levels[index]}',
                                  price: '${prices[index]} ${context.translate('currency')}',
                                  lessons: '24 ${context.translate('lessons_count')}',
                                  duration: '8 ${context.translate('weeks_count')}',
                                );
                              },
                            ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context, {
    required String title,
    required String price,
    required String lessons,
    required String duration,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final isLoggedIn = await sl<AuthRepo>().isLoggedIn();
            if (isLoggedIn) {
              if (context.mounted) {
                CustomSnackBar.show(
                  context,
                  message: context.translate('journey_welcome'),
                  type: SnackBarType.success,
                );
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (context.mounted) {
                    Navigator.pushNamed(context, AppRoutes.levels);
                  }
                });
              }
            } else {
              if (context.mounted) {
                _showAccessDeniedDialog(context);
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('🇩🇪', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                lessons,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                duration,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    price,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructorIntro(BuildContext context) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 800),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('who_is_instructor'),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.translate('instructor_desc'),
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.instructorBio),
                      child: Text(
                        context.translate('view_cv'),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/khaled.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookTeaser(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is! AdminLoadedState || state.books.isEmpty) {
          return const SizedBox.shrink();
        }
        final book = state.books.first;
        if (!book.isAvailable) return const SizedBox.shrink();

        return FadeInUp(
          duration: const Duration(milliseconds: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.book),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFF172554), // Deep Navy
                        Color(0xFF1E3A8A), // Navy Blue
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlueDark.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -10,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Book Cover mini
                            Container(
                              width: 80,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(3, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Column(
                                  children: [
                                    Container(height: 5, color: AppColors.primaryBlueLight),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/deutsch_welt.jpeg',
                                              height: 36,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Deutsche\nWelt',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.cairo(
                                                fontSize: 7,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(height: 5, color: AppColors.primaryBlue),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlueLight.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '📚 كتاب جديد',
                                      style: GoogleFonts.cairo(
                                        color: AppColors.primaryBlueLight,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    book.title,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    book.subtitle,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        '${book.price.toStringAsFixed(0)} جنيه',
                                        style: GoogleFonts.cairo(
                                          color: AppColors.primaryBlueLight,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'تفاصيل',
                                              style: GoogleFonts.cairo(
                                                color: AppColors.primaryBlue,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 10,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(
              context.translate('access_denied'),
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          context.translate('access_denied_desc'),
          style: GoogleFonts.cairo(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.translate('close'),
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.signUp);
            },
            child: Text(context.translate('register_now_btn')),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return const StudentReviewsSlider();
  }

  Widget _buildFAQSection() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              FadeInLeft(
                child: Text(
                  context.translate('faq_title'),
                  style: GoogleFonts.cairo(
                    fontSize: isTablet ? 30 : 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(3, (index) {
                final questions = [
                  'faq_q1',
                  'faq_q2',
                  'faq_q3',
                ];
                final answers = [
                  'faq_a1',
                  'faq_a2',
                  'faq_a3',
                ];
                return FadeInUp(
                  delay: Duration(milliseconds: index * 150),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    // ✅ FIX: ExpansionTile needs an explicit Material ancestor
                    // with a non-transparent color so its InkWell splash renders.
                    child: Material(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        title: Text(
                          context.translate(questions[index]),
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(context).textTheme.titleMedium?.color ?? AppColors.textPrimary,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              context.translate(answers[index]),
                              style: GoogleFonts.cairo(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return FutureBuilder<AppSettingsModel>(
      future: AppSettingsService.loadSettings(),
      builder: (context, snapshot) {
        final settings = snapshot.data ?? AppSettingsModel.defaultSettings();

        return Container(
          width: double.infinity,
          color: AppColors.primaryBlueDark,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 60 : 24,
            vertical: 40,
          ),
          child: isTablet
              ? Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Column 1: Branding & Description
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.accentGold.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  'Deutsch Welt',
                                  style: GoogleFonts.cairo(
                                    color: AppColors.accentGold,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.translate('academy_desc'),
                                style: GoogleFonts.cairo(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  _socialIcon(
                                    Icons.facebook,
                                    onTap: () => _launchUrl(settings.facebookUrl),
                                  ),
                                  const SizedBox(width: 12),
                                  _socialIcon(
                                    Icons.play_circle_fill_rounded,
                                    onTap: () => _launchUrl(settings.youtubeUrl),
                                  ),
                                  const SizedBox(width: 12),
                                  _socialIcon(
                                    Icons.camera_alt_rounded,
                                    onTap: () => _launchUrl(settings.instagramUrl),
                                  ),
                                  const SizedBox(width: 12),
                                  _socialIcon(
                                    Icons.music_note_rounded,
                                    onTap: () => _launchUrl(settings.tiktokUrl),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        // Column 2: Quick Links
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.translate('quick_links'),
                                style: GoogleFonts.cairo(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildPillLink(
                                    context,
                                    context.translate('home'),
                                    onTap: () {
                                      _scrollController.animateTo(
                                        0,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  ),
                                  _buildPillLink(
                                    context,
                                    context.translate('courses'),
                                    onTap: () {
                                      if (_coursesSectionKey.currentContext != null) {
                                        Scrollable.ensureVisible(
                                          _coursesSectionKey.currentContext!,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  ),
                                  _buildPillLink(
                                    context,
                                    context.translate('who_is_herr_khaled'),
                                    onTap: () => Navigator.pushNamed(
                                        context, AppRoutes.instructorBio),
                                  ),
                                  _buildPillLink(
                                    context,
                                    context.translate('privacy_policy'),
                                    onTap: () => Navigator.pushNamed(
                                        context, AppRoutes.privacy),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Column 3: Support
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.translate('technical_support_title'),
                                style: GoogleFonts.cairo(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSupportButton(settings.supportNumber1),
                              const SizedBox(height: 10),
                              _buildSupportButton(settings.supportNumber2),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 20),
                    Text(
                      context.translate('all_rights_reserved'),
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const PoweredByDeveloperWidget(isDarkBackground: true),
                  ],
                )
              : Column(
                  children: [
                    // Branding Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Deutsch Welt',
                        style: GoogleFonts.cairo(
                          color: AppColors.accentGold,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.translate('academy_desc'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Social Icons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialIcon(
                          Icons.facebook,
                          iconColor: const Color(0xFF1877F2), // Facebook Blue
                          onTap: () => _launchUrl(settings.facebookUrl),
                        ),
                        const SizedBox(width: 16),
                        _socialIcon(
                          Icons.play_circle_fill_rounded,
                          iconColor: const Color(0xFFFF0000), // YouTube Red
                          onTap: () => _launchUrl(settings.youtubeUrl),
                        ),
                        const SizedBox(width: 16),
                        _socialIcon(
                          Icons.camera_alt_rounded,
                          iconColor: const Color(0xFFE1306C), // Instagram Pink
                          onTap: () => _launchUrl(settings.instagramUrl),
                        ),
                        const SizedBox(width: 16),
                        _socialIcon(
                          Icons.music_note_rounded,
                          iconColor: const Color(0xFF00F2EA), // TikTok Cyan
                          onTap: () => _launchUrl(settings.tiktokUrl),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 30),

                    // 🏢 Official Academy Branches Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.accentGold, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'فروع أكاديمية Deutsch Welt المعتمدة 🏢📍',
                            style: GoogleFonts.cairo(
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildBranchChip(
                          context,
                          '📍 فرع مدينة نصر (القاهرة)',
                          'https://maps.app.goo.gl/i55RDUisL7wcdwf3A',
                          '16 ش شريف سامي - بالقرب من (كوبري المنهل / جامع السلام) - الدور الأول 🏢',
                        ),
                        _buildBranchChip(
                          context,
                          '📍 فرع شبين الكوم (المنوفية)',
                          'https://maps.app.goo.gl/NJRj414R5yurS7Gs8?g_st=ac',
                          'برج حجازي – الدور الثاني علوي - أمام مستشفى الجامعة مباشرة 🏥',
                        ),
                        _buildBranchChip(
                          context,
                          '📍 فرع المنصورة (الدقهلية)',
                          'https://maps.app.goo.gl/PpTdBa3fkWC7WGYt5',
                          '1 شارع الشيخ الغزالي أمام مستشفى الجامعة البوابة الرئيسية 🏥',
                        ),
                        _buildBranchChip(
                          context,
                          '📍 فرع طنطا (الغربية)',
                          'https://maps.app.goo.gl/2et31MeUFJUjC3jV6?g_st=ac',
                          '1 هالة توفيق مع البحر (فوق محل عباد الرحمن ومكتبة الرسالة) - الدور الأول 🌺',
                        ),
                        _buildBranchChip(
                          context,
                          '🌐 التعليم أونلاين (جميع المحافظات)',
                          'https://wa.me/201055287454',
                          'منصة ألمانية بإتقان أونلاين لجميع الطلاب من كافة المحافظات والدول 🌍',
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 30),

                    // Quick Links
                    Text(
                      context.translate('quick_links'),
                      style: GoogleFonts.cairo(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildPillLink(context, context.translate('home'), onTap: () {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }),
                        _buildPillLink(context, context.translate('courses'), onTap: () {
                          if (_coursesSectionKey.currentContext != null) {
                            Scrollable.ensureVisible(
                              _coursesSectionKey.currentContext!,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        }),
                        _buildPillLink(
                          context,
                          context.translate('who_is_herr_khaled'),
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.instructorBio),
                        ),
                        _buildPillLink(
                          context,
                          context.translate('privacy_policy'),
                          onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Support Section
                    Text(
                      context.translate('technical_support_title'),
                      style: GoogleFonts.cairo(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSupportButton(settings.supportNumber1),
                    const SizedBox(height: 12),
                    _buildSupportButton(settings.supportNumber2),

                    const SizedBox(height: 40),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 20),

                    Text(
                      context.translate('all_rights_reserved'),
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const PoweredByDeveloperWidget(isDarkBackground: true),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildBranchChip(BuildContext context, String name, String mapUrl, String addressDetails) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showBranchMapModal(context, name, mapUrl, addressDetails),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.map_rounded, color: Color(0xFF60A5FA), size: 14),
            ],
          ),
        ),
      ),
    );
  }

  void _showBranchMapModal(BuildContext context, String title, String mapUrl, String addressDetails) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_rounded, color: AppColors.primaryBlue, size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              addressDetails,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.map_rounded, size: 20),
              label: Text(
                'فتح اللوكيشن في Google Maps 🗺️',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                if (!await launchUrl(Uri.parse(mapUrl), mode: LaunchMode.externalApplication)) {
                  if (context.mounted) {
                    CustomSnackBar.show(context, message: 'تعذر فتح خرائط جوجل', type: SnackBarType.error);
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                side: const BorderSide(color: AppColors.primaryBlue),
              ),
              icon: const Icon(Icons.phone_rounded, color: AppColors.primaryBlue, size: 20),
              label: Text(
                'التواصل المباشر مع الأكاديمية 📞',
                style: GoogleFonts.cairo(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                _launchWhatsApp('01055287454');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPillLink(
    BuildContext context,
    String text, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            text,
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchWhatsApp(number),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                number,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    var cleanNum = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNum.startsWith('01')) {
      cleanNum = '2$cleanNum';
    }
    final message = Uri.encodeComponent("مرحباً، أود الاستفسار بخصوص كورسات اللغة الألمانية والاشتراك في المنصة 🇩🇪✨");
    final url = "https://wa.me/$cleanNum?text=$message";

    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      if (mounted) {
        CustomSnackBar.show(context, message: 'لا يمكن فتح الواتساب حالياً', type: SnackBarType.error);
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _socialIcon(IconData icon, {VoidCallback? onTap, Color iconColor = Colors.white}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                iconColor.withValues(alpha: 0.25),
                iconColor.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 30),
        ),
      ),
    );
  }

  Widget _buildReviewVideoSection() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 32.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section header with icon
          FadeInLeft(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'رأي طالب بالفيديو',
                  style: GoogleFonts.cairo(
                    fontSize: isTablet ? 30 : 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'شوف بنفسك رأي طلابنا في تجربتهم معانا',
              style: GoogleFonts.cairo(
                fontSize: isTablet ? 16 : 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: const LocalVideoPlayer(
              assetPath: 'assets/videos/video_reviews.mp4',
            ),
          ),
        ],
      ),
    );
  }
}