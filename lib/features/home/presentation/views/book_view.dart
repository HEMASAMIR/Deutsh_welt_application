import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/custom_snack_bar.dart';

import '../../../books/data/models/book_api_model.dart';
import '../../../books/presentation/cubit/books_cubit.dart';
import '../../../books/presentation/cubit/books_state.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Level meta — color & gradient per CEFR level
// ──────────────────────────────────────────────────────────────────────────────
class _LevelMeta {
  final Color primary;
  final Color secondary;
  final Color accent;
  final LinearGradient gradient;
  final String emoji;
  final String label;

  const _LevelMeta({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.gradient,
    required this.emoji,
    required this.label,
  });

  static _LevelMeta forLevel(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return const _LevelMeta(
          primary: Color(0xFF059669),
          secondary: Color(0xFF047857),
          accent: Color(0xFF34D399),
          gradient: LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          emoji: '🌱',
          label: 'مبتدئ',
        );
      case 'A2':
        return const _LevelMeta(
          primary: Color(0xFF0891B2),
          secondary: Color(0xFF0E7490),
          accent: Color(0xFF38BDF8),
          gradient: LinearGradient(
            colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          emoji: '🚀',
          label: 'مبتدئ متقدم',
        );
      case 'B1':
        return const _LevelMeta(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFF6D28D9),
          accent: Color(0xFFA78BFA),
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          emoji: '⭐',
          label: 'متوسط',
        );
      case 'B2':
        return const _LevelMeta(
          primary: Color(0xFFD97706),
          secondary: Color(0xFFB45309),
          accent: Color(0xFFFBBF24),
          gradient: LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFB45309)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          emoji: '🏆',
          label: 'متوسط متقدم',
        );
      default:
        return const _LevelMeta(
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryBlueDark,
          accent: AppColors.primaryBlueLight,
          gradient: AppColors.primaryGradient,
          emoji: '📚',
          label: 'متقدم',
        );
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// BookView — Entry point
// ──────────────────────────────────────────────────────────────────────────────
class BookView extends StatelessWidget {
  const BookView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BooksCubit>()..fetchBooks(),
      child: const _BookViewBody(),
    );
  }
}

class _BookViewBody extends StatefulWidget {
  const _BookViewBody();

  @override
  State<_BookViewBody> createState() => _BookViewBodyState();
}

class _BookViewBodyState extends State<_BookViewBody>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _pulseController;
  late Animation<double> _headerAnim;
  late Animation<double> _pulseAnim;

  // Track which book is currently downloading
  int? _downloadingBookId;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _headerAnim = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Download handler ─────────────────────────────────────────────────────
  Future<void> _handleDownload(
      BuildContext context, BookApiModel book) async {
    setState(() => _downloadingBookId = book.id);

    try {
      final cubit = context.read<BooksCubit>();
      await cubit.downloadBook(book.id);

      // Listen for the success state
      if (!context.mounted) return;
      final state = cubit.state;
      if (state is BookDownloadSuccess) {
        await _saveAndOpenFile(context, book, state.bytes);
      } else if (state is BookDownloadError) {
        if (context.mounted) {
          CustomSnackBar.show(
            context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      }
    } finally {
      if (mounted) setState(() => _downloadingBookId = null);
    }
  }

  Future<void> _saveAndOpenFile(
      BuildContext context, BookApiModel book, List<int> bytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final safeName = book.name
          .replaceAll(RegExp(r'[^\w\s\-]'), '')
          .replaceAll(' ', '_');
      final file = File('${dir.path}/$safeName.pdf');
      await file.writeAsBytes(bytes, flush: true);

      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '✅ تم تحميل الكتاب بنجاح! محفوظ في: ${file.path}',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'حدث خطأ أثناء حفظ الملف. تأكد من صلاحيات التخزين.',
          type: SnackBarType.error,
        );
      }
    }
  }

  // ── Purchase via WhatsApp ────────────────────────────────────────────────
  Future<void> _purchaseViaWhatsApp(
      BuildContext context, BookApiModel book) async {
    final userStr = sl<StorageService>().user;
    String studentName = 'طالب';
    String studentPhone = '';

    if (userStr != null) {
      try {
        final userData = jsonDecode(userStr);
        final first = userData['first_name'] ?? '';
        final last = userData['last_name'] ?? '';
        studentName = '$first $last'.trim();
        if (studentName.isEmpty) studentName = 'طالب';
        studentPhone =
            userData['phone'] ?? userData['phone_number'] ?? '';
      } catch (_) {}
    }

    final isUnavailable = !book.isActive || book.level.toUpperCase() == 'B2';
    final meta = _LevelMeta.forLevel(book.level);
    final String message;
    if (isUnavailable) {
      message = Uri.encodeComponent(
        '📚 *استفسار عن موعد توفر كتاب ${book.name}* ${meta.emoji}\n\n'
        '━━━━━━━━━━━━━━━━━━\n'
        '👤 *الطالب:* $studentName\n'
        '📞 *الهاتف:* ${studentPhone.isNotEmpty ? studentPhone : "غير محدد"}\n'
        '📖 *الكتاب:* ${book.name}\n'
        '🎯 *المستوى:* ${book.level} - ${meta.label}\n'
        '━━━━━━━━━━━━━━━━━━\n\n'
        'أهلاً هير خالد، حابب أستفسر عن موعد توفر كتاب المستوى B2 وإمكانية الحجز المسبق ✨',
      );
    } else {
      message = Uri.encodeComponent(
        '📚 *طلب شراء كتاب ${book.name}* ${meta.emoji}\n\n'
        '━━━━━━━━━━━━━━━━━━\n'
        '👤 *الطالب:* $studentName\n'
        '📞 *الهاتف:* ${studentPhone.isNotEmpty ? studentPhone : "غير محدد"}\n'
        '📖 *الكتاب:* ${book.name}\n'
        '🎯 *المستوى:* ${book.level} - ${meta.label}\n'
        '💰 *السعر:* ${book.formattedPrice}\n'
        '💵 *طريقة التحويل:* فودافون كاش / إنستا باي\n'
        '━━━━━━━━━━━━━━━━━━\n\n'
        'أرجو تفعيل الوصول للكتاب على الحساب ✨',
      );
    }

    const adminNumber = '+201055287454';
    final whatsappUrl = 'https://wa.me/$adminNumber?text=$message';

    if (!await launchUrl(Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'تعذّر فتح واتساب. تأكد من تثبيته.',
          type: SnackBarType.error,
        );
      }
    }
  }

  // ── Login guard ──────────────────────────────────────────────────────────
  bool _requireLogin(BuildContext context) {
    if (sl<StorageService>().user == null) {
      _showLoginDialog(context);
      return true;
    }
    return false;
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(children: [
          const Icon(Icons.lock_rounded, color: AppColors.warning),
          const SizedBox(width: 8),
          Text('تسجيل الدخول مطلوب',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        ]),
        content: Text(
          'يجب تسجيل الدخول أولاً للوصول إلى هذه الميزة.',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, AppRoutes.login);
            },
            child: Text('تسجيل الدخول',
                style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<BooksCubit, BooksState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Header ─────────────────────────────────────────────
              _buildSliverHeader(context),

              // ── Content ─────────────────────────────────────────────────
              if (state is BooksLoading || state is BooksInitial)
                SliverToBoxAdapter(child: _buildShimmer(context))
              else
                ..._buildLevelSections(context, state),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  // ── Sliver AppBar / Hero ─────────────────────────────────────────────────
  SliverAppBar _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primaryBlueDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: FadeTransition(
          opacity: _headerAnim,
          child: Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  right: -40,
                  top: -40,
                  child: _decorativeCircle(200, 0.06),
                ),
                Positioned(
                  left: -50,
                  bottom: -30,
                  child: _decorativeCircle(180, 0.05),
                ),
                Positioned(
                  right: 60,
                  bottom: 20,
                  child: _decorativeCircle(60, 0.08),
                ),
                // German flag stripe top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(height: 4, color: const Color(0xFFFFCC02)),
                ),
                // Content
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(_headerAnim),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              // Animated book icon
                              ScaleTransition(
                                scale: _pulseAnim,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.25),
                                        width: 1.5),
                                  ),
                                  child: const Icon(
                                      Icons.menu_book_rounded,
                                      color: Colors.white,
                                      size: 30),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'مكتبة الكتب 📚',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Deutsch Lernhilfe - Schritt für Schritt',
                                      style: GoogleFonts.roboto(
                                        color: Colors.white
                                            .withValues(alpha: 0.8),
                                        fontSize: 12,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Level badges row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ['A1', 'A2', 'B1', 'B2'].map((lvl) {
                                final meta = _LevelMeta.forLevel(lvl);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: meta.primary
                                          .withValues(alpha: 0.25),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: meta.accent
                                            .withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${meta.emoji} $lvl',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
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
        ),
      ),
    );
  }

  Widget _decorativeCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  // ── Shimmer Loading ──────────────────────────────────────────────────────
  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(3, (i) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  height: 28,
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Error State ──────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          FadeInDown(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.error, size: 44),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            child: Text(
              'تعذّر تحميل الكتب',
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          const SizedBox(height: 28),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: Text('إعادة المحاولة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => context.read<BooksCubit>().fetchBooks(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const SizedBox(height: 40),
          FadeInDown(
            child: const Icon(Icons.library_books_rounded,
                size: 72, color: AppColors.textHint),
          ),
          const SizedBox(height: 20),
          Text('لا توجد كتب متاحة حالياً',
              style: GoogleFonts.cairo(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }

  // ── Level Sections ───────────────────────────────────────────────────────
  List<Widget> _buildLevelSections(BuildContext context, BooksState state) {
    Map<String, List<BookApiModel>> books = {};
    if (state is BooksLoaded) {
      books = state.books;
    }
    // During download or after error, books map may be empty
    // but the BlocBuilder re-renders when cubit emits BooksLoaded again

    if (books.isEmpty) {
      books = {
        'A1': [
          const BookApiModel(
            id: 1,
            name: 'Deutsch Lernhilfe Schritt für Schritt - A1',
            level: 'A1',
            price: '500.00',
            isActive: true,
            hasAccess: false,
          ),
        ],
        'A2': [
          const BookApiModel(
            id: 3,
            name: 'Deutsch Lernhilfe Schritt für Schritt - A2',
            level: 'A2',
            price: '500.00',
            isActive: true,
            hasAccess: false,
          ),
        ],
        'B1': [
          const BookApiModel(
            id: 2,
            name: 'Deutsch Lernhilfe Schritt für Schritt - B1',
            level: 'B1',
            price: '500.00',
            isActive: true,
            hasAccess: false,
          ),
        ],
        'B2': [
          const BookApiModel(
            id: 4,
            name: 'Deutsch Lernhilfe Schritt für Schritt - B2',
            level: 'B2',
            price: '500.00',
            isActive: false,
            hasAccess: false,
          ),
        ],
      };
    }

    if (!books.containsKey('B2') || books['B2']!.isEmpty) {
      books['B2'] = [
        const BookApiModel(
          id: 4,
          name: 'Deutsch Lernhilfe Schritt für Schritt - B2',
          level: 'B2',
          price: '500.00',
          isActive: false,
          hasAccess: false,
        ),
      ];
    }

    // Sort levels: A1 → A2 → B1 → B2
    final levelOrder = ['A1', 'A2', 'B1', 'B2'];
    final sortedLevels = books.keys.toList()
      ..sort((a, b) {
        final ai = levelOrder.indexOf(a.toUpperCase());
        final bi = levelOrder.indexOf(b.toUpperCase());
        if (ai == -1 && bi == -1) return a.compareTo(b);
        if (ai == -1) return 1;
        if (bi == -1) return -1;
        return ai.compareTo(bi);
      });

    final widgets = <Widget>[];
    int sectionIndex = 0;

    for (final level in sortedLevels) {
      final levelBooks = books[level] ?? [];
      if (levelBooks.isEmpty) continue;
      final meta = _LevelMeta.forLevel(level);

      widgets.add(
        SliverToBoxAdapter(
          child: FadeInUp(
            delay: Duration(milliseconds: 100 + sectionIndex * 120),
            duration: const Duration(milliseconds: 500),
            child: _buildLevelSection(
                context, level, meta, levelBooks, sectionIndex),
          ),
        ),
      );
      sectionIndex++;
    }

    return widgets;
  }

  // ── Single Level Section ─────────────────────────────────────────────────
  Widget _buildLevelSection(
    BuildContext context,
    String level,
    _LevelMeta meta,
    List<BookApiModel> books,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          _buildSectionHeader(meta, level),
          const SizedBox(height: 14),
          // Book cards
          ...books.asMap().entries.map((entry) {
            return FadeInRight(
              delay: Duration(
                  milliseconds: 60 + index * 80 + entry.key * 100),
              duration: const Duration(milliseconds: 450),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _BookCard(
                  book: entry.value,
                  meta: meta,
                  isDownloading:
                      _downloadingBookId == entry.value.id,
                  onDownload: () {
                    if (_requireLogin(context)) return;
                    _handleDownload(context, entry.value);
                  },
                  onPurchase: () {
                    if (_requireLogin(context)) return;
                    _purchaseViaWhatsApp(context, entry.value);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(_LevelMeta meta, String level) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: meta.gradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: meta.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                meta.emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'المستوى $level',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            meta.label,
            style: GoogleFonts.cairo(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _BookCard — Advanced animated book card
// ──────────────────────────────────────────────────────────────────────────────
class _BookCard extends StatefulWidget {
  final BookApiModel book;
  final _LevelMeta meta;
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onPurchase;

  const _BookCard({
    required this.book,
    required this.meta,
    required this.isDownloading,
    required this.onDownload,
    required this.onPurchase,
  });

  @override
  State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _pressController;
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressController.reverse();
  void _onTapUp(TapUpDetails _) => _pressController.forward();
  void _onTapCancel() => _pressController.forward();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? widget.meta.primary.withValues(alpha: 0.3)
        : widget.meta.primary.withValues(alpha: 0.15);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.meta.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                // ── Coloured top stripe ──────────────────────────────────
                _buildCardHeader(),
                // ── Body ─────────────────────────────────────────────────
                _buildCardBody(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Coloured header strip with level badge and book icon
  Widget _buildCardHeader() {
    return Container(
      height: 8,
      decoration: BoxDecoration(gradient: widget.meta.gradient),
    );
  }

  Widget _buildCardBody(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Book info row ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover widget
              _buildBookCover(),
              const SizedBox(width: 16),
              // Book details
              Expanded(child: _buildBookDetails(context, isDark)),
            ],
          ),

          const SizedBox(height: 16),

          // ── Action button ─────────────────────────────────────────────
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildBookCover() {
    return Container(
      width: 72,
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.meta.primary.withValues(alpha: 0.1),
            widget.meta.secondary.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(
          color: widget.meta.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.meta.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Column(
          children: [
            // Level color bar top
            Container(
              height: 6,
              decoration: BoxDecoration(gradient: widget.meta.gradient),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Try to load logo, fallback to icon
                  Image.asset(
                    'assets/images/deutsch_welt.jpeg',
                    height: 36,
                    width: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.menu_book_rounded,
                      color: widget.meta.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: widget.meta.gradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.book.level,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Level color bar bottom
            Container(
              height: 4,
              decoration: BoxDecoration(gradient: widget.meta.gradient),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookDetails(BuildContext context, bool isDark) {
    final textPrimary =
        isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? Colors.white60 : AppColors.textSecondary;
    final isUnavailable = !widget.book.isActive || widget.book.level.toUpperCase() == 'B2';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book name
        Text(
          widget.book.name,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            height: 1.35,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),

        // Access status badge
        _buildAccessBadge(),
        const SizedBox(height: 10),

        if (isUnavailable) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.meta.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.meta.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: widget.meta.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '✨ غير متوفر حالياً | نعمل على إعداد وتجهيز كتاب B2 بعناية فائقة ليكون مرجعك المثالي ونقلتك نحو إتقان اللغة الألمانية والطلاقة فيها.. انتظرونا قريباً ⏳🇩🇪',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      height: 1.4,
                      color: isDark ? Colors.amber[200] : const Color(0xFFB45309),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Price row
          Row(
            children: [
              const Icon(Icons.sell_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'السعر:',
                style: GoogleFonts.cairo(
                    fontSize: 12, color: textSecondary),
              ),
              const SizedBox(width: 4),
              ShaderMask(
                shaderCallback: (bounds) =>
                    widget.meta.gradient.createShader(bounds),
                child: Text(
                  widget.book.formattedPrice,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAccessBadge() {
    final isUnavailable = !widget.book.isActive || widget.book.level.toUpperCase() == 'B2';

    if (isUnavailable) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFD97706).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: const Color(0xFFD97706).withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time_rounded,
                size: 13, color: Color(0xFFD97706)),
            const SizedBox(width: 4),
            Text(
              'غير متوفر حالياً ⏳',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: const Color(0xFFD97706),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (widget.book.hasAccess) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: const Color(0xFF059669).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_rounded,
                size: 13, color: Color(0xFF059669)),
            const SizedBox(width: 4),
            Text(
              'لديك صلاحية الوصول ✅',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: const Color(0xFF059669),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded,
                size: 13, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              'غير مفعّل بعد',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _openPreviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BookPreviewModal(book: widget.book, meta: widget.meta, onPurchase: widget.onPurchase),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final isUnavailable = !widget.book.isActive || widget.book.level.toUpperCase() == 'B2';

    if (isUnavailable) {
      return Column(
        children: [
          // ── Preview Button ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.primaryBlue),
              label: Text(
                'معاينة عينة من منهج B2 👁️',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primaryBlue,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 11),
                side: BorderSide(color: widget.meta.primary.withValues(alpha: 0.4), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _openPreviewModal(context),
            ),
          ),
          const SizedBox(height: 8),

          // ── Inquire / Coming Soon Action Button ─────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18, color: Colors.white),
              label: Text(
                'استفسر عن موعد التوفر عبر واتساب 💬',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                backgroundColor: const Color(0xFFD97706),
              ),
              onPressed: widget.onPurchase,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // ── Preview Button ──────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.primaryBlue),
            label: Text(
              'معاينة عينة مجانية من الكتاب 👁️',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.primaryBlue,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 11),
              side: BorderSide(color: widget.meta.primary.withValues(alpha: 0.4), width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _openPreviewModal(context),
          ),
        ),
        const SizedBox(height: 8),

        // ── Download / Purchase Action Button ───────────────────────────────
        if (widget.book.hasAccess)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: widget.isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download_rounded, size: 20, color: Colors.white),
              label: Text(
                widget.isDownloading ? 'جاري تحميل الكتاب...' : 'تحميل الكتاب PDF 📥',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.meta.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: widget.isDownloading ? null : widget.onDownload,
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18, color: Colors.white),
              label: Text(
                'اشتري الآن عبر واتساب 💬',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                backgroundColor: const Color(0xFF25D366),
              ),
              onPressed: widget.onPurchase,
            ),
          ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _BookPreviewModal — Interactive Book Preview Component
// ──────────────────────────────────────────────────────────────────────────────
class _BookPreviewModal extends StatefulWidget {
  final BookApiModel book;
  final _LevelMeta meta;
  final VoidCallback onPurchase;

  const _BookPreviewModal({
    required this.book,
    required this.meta,
    required this.onPurchase,
  });

  @override
  State<_BookPreviewModal> createState() => _BookPreviewModalState();
}

class _BookPreviewModalState extends State<_BookPreviewModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, dynamic>> _getPreviewPages() {
    final isUnavailable = !widget.book.isActive || widget.book.level.toUpperCase() == 'B2';
    if (isUnavailable) {
      return [
        {
          'title': 'كتاب B2 قيد التجهيز والإعداد ⌛',
          'subtitle': 'دليلك للوصول إلى المستوى المتقدم في اللغة الألمانية مع Herr / خالد الحلواني',
          'content': [
            '• الوحدة الأولى: B2 Passiv & Konjunktiv II (القواعد المتقدمة)',
            '• الوحدة الثانية: Redemittel & Debatten (الأساليب والمناظرات)',
            '• الوحدة الثالثة: Schreiben & Briefe (كتابة المقالات والرسائل الرسمية)',
            '• الوحدة الرابعة: Goethe B2 & telc B2 Vorbereitung (التحضير للامتحانات الدولية)',
          ],
          'highlight': '⏳ كتاب B2 حالياً في مرحلة المراجعة والطباعة لتقديم تجربة شروحات استثنائية وبأعلى جودة.',
        },
        {
          'title': 'قريباً إن شاء الله 🌟',
          'subtitle': 'تابعنا على المنصة للتعرف على موعد الصدور',
          'content': [
            '1. يتم تصميم وتنسيق كتاب B2 بعناية فائقة ليشمل كامل أجزاء الامتحان.',
            '2. يحتوي على مئات التدريبات والحلول النموذجية الميسرة.',
            '3. يمكنك التواصل مباشرة عبر واتساب لحجز نسختك مسبقاً وفور صدورها.',
          ],
          'highlight': '✨ انتظرونا قريباً للحصول على النسخة الكاملة الحصرية فور توفرها.',
        },
      ];
    }

    return [
      {
        'title': 'فهرس منهج ${widget.book.level} 📌',
        'subtitle': 'دليلك الشامل لتعلم الألمانية خطوة بخطوة مع Herr / خالد الحلواني',
        'content': [
          '• الوحدة الأولى: Begrüßung & Vorstellen (التحيات والتعارف)',
          '• الوحدة الثانية: Die Grammatik (الأفعال وأدوات المعرفة Der/Die/Das)',
          '• الوحدة الثالثة: Im Alltag (الحياة اليومية والتسوق)',
          '• الوحدة الرابعة: Reisen & Mobilität (السفر والمواصلات)',
          '• ملحق خاص: نماذج امتحان جوتة Goethe-Zertifikat الرسمية',
        ],
        'highlight': 'تغطية 100% لمقرر السفارة والجوتة مع الشرح العربي الميسر.',
      },
      {
        'title': 'عينة الدرس الأول: Grammatik 🇩🇪',
        'subtitle': 'طريقة الشرح المميزة مع Herr / خالد الحلواني',
        'content': [
          '1. Bestimmter Artikel (أدوات المعرفة):',
          '   - Der (المذكر): der Mann (الرجل), der Tisch (الطاولة)',
          '   - Die (المؤنث): die Frau (السيدة), die Sonne (الشمس)',
          '   - Das (المحايد): das Kind (الطفل), das Buch (الكتاب)',
          '2. القاعدة الذهبية: حفظ الكلمة بأداتها ولونها لتسهيل التذكر السريع.',
        ],
        'highlight': '💡 معلومة هامة: أدوات المعرفة تضمن لك 40% من درجات القواعد بالامتحان!',
      },
      {
        'title': 'تدريبات تفاعلية وحوارات 💬',
        'subtitle': 'Dialoge im Alltag & Übungen',
        'content': [
          '• Hallo! Wie heißen Sie? (أهلاً! ما اسمك؟)',
          '  - Ich heiße Ahmed und komme aus Ägypten. (اسمي أحمد وأنا من مصر.)',
          '• Was machen Sie beruflich? (ما هي مهنتك؟)',
          '  - Ich bin Deutschlerner! (أنا أتعلم اللغة الألمانية!)',
        ],
        'highlight': 'يحتوي الكتاب على أكثر من 50 حوار جاهز للاستخدام اليومي والامتحانات الشفهية.',
      },
      {
        'title': 'ملخص نصائح امتحان Goethe & telc 🏆',
        'subtitle': 'كيف تحصل على أعلى الدرجات بكل سهولة',
        'content': [
          '✔ قسم Hören (الاستماع): التركيز على الكلمات المفتاحية في السؤال أولاً.',
          '✔ قسم Schreiben (الكتابة): استخدام الروابط البسيطة (und, aber, denn).',
          '✔ قسم Sprechen (التحدث): التحدث بثقة واستخدام الحوارات التدريبية من الكتاب.',
        ],
        'highlight': 'شامل إجابات نموذجية كاملة لجميع التمارين الواردة بالكتاب.',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPreviewPages();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: widget.meta.gradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.book.level,
                    style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'معاينة عينة من الكتاب 📖',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Page Indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: widget.meta.primary.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (idx) {
                final isActive = idx == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? widget.meta.primary : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),

          // PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemCount: pages.length,
              itemBuilder: (context, idx) {
                final item = pages[idx];
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: widget.meta.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title'],
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: widget.meta.primary),
                            ),
                            Text(
                              'صفحة ${idx + 1} من ${pages.length}',
                              style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['subtitle'],
                          style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const Divider(height: 20),
                        Expanded(
                          child: ListView(
                            children: (item['content'] as List<String>).map((line) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  line,
                                  style: GoogleFonts.cairo(fontSize: 13.5, height: 1.6),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.meta.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star_rounded, color: widget.meta.primary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['highlight'],
                                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: widget.meta.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 20, color: Colors.white),
                  label: Text(
                    'اطلب النسخة الكاملة الآن عبر واتساب 🚀',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onPurchase();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

