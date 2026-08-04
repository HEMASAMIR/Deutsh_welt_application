import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snack_bar.dart';

class BranchLocationData {
  final String id;
  final String name;
  final String city;
  final String address;
  final String googleMapsUrl;
  final double lat;
  final double lon;
  final String embedUrl;

  BranchLocationData({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.googleMapsUrl,
    required this.lat,
    required this.lon,
    required this.embedUrl,
  });
}

class BranchesMapWidget extends StatefulWidget {
  const BranchesMapWidget({super.key});

  @override
  State<BranchesMapWidget> createState() => _BranchesMapWidgetState();
}

class _BranchesMapWidgetState extends State<BranchesMapWidget>
    with SingleTickerProviderStateMixin {
  final List<BranchLocationData> _branches = [
    BranchLocationData(
      id: 'nasr_city',
      name: 'فرع مدينة نصر',
      city: 'القاهرة',
      address:
          '16 شارع شريف سامي - بالقرب من (كوبري المنهل / جامع السلام) - الدور الأول 🏢',
      googleMapsUrl: 'https://maps.app.goo.gl/i55RDUisL7wcdwf3A',
      lat: 30.0561,
      lon: 31.3301,
      embedUrl:
          'https://www.openstreetmap.org/export/embed.html?bbox=31.3101%2C30.0361%2C31.3501%2C30.0761&layer=mapnik&marker=30.0561%2C31.3301',
    ),
    BranchLocationData(
      id: 'shebin',
      name: 'فرع شبين الكوم',
      city: 'المنوفية',
      address: 'برج حجازي – الدور الثاني علوي - أمام مستشفى الجامعة مباشرة 🏥',
      googleMapsUrl: 'https://maps.app.goo.gl/NJRj414R5yurS7Gs8?g_st=ac',
      lat: 30.5503,
      lon: 31.0106,
      embedUrl:
          'https://www.openstreetmap.org/export/embed.html?bbox=30.9906%2C30.5303%2C31.0306%2C30.5703&layer=mapnik&marker=30.5503%2C31.0106',
    ),
    BranchLocationData(
      id: 'mansoura',
      name: 'فرع المنصورة',
      city: 'الدقهلية',
      address: '1 شارع الشيخ الغزالي - أمام مستشفى الجامعة البوابة الرئيسية 🏥',
      googleMapsUrl: 'https://maps.app.goo.gl/PpTdBa3fkWC7WGYt5',
      lat: 31.0379,
      lon: 31.3639,
      embedUrl:
          'https://www.openstreetmap.org/export/embed.html?bbox=31.3439%2C31.0179%2C31.3839%2C31.0579&layer=mapnik&marker=31.0379%2C31.3639',
    ),
    BranchLocationData(
      id: 'tanta',
      name: 'فرع طنطا',
      city: 'الغربية',
      address:
          '1 هالة توفيق مع البحر (فوق محل عباد الرحمن ومكتبة الرسالة) - الدور الأول 🌺',
      googleMapsUrl: 'https://maps.app.goo.gl/2et31MeUFJUjC3jV6?g_st=ac',
      lat: 30.7865,
      lon: 31.0004,
      embedUrl:
          'https://www.openstreetmap.org/export/embed.html?bbox=30.9804%2C30.7665%2C31.0204%2C30.8065&layer=mapnik&marker=30.7865%2C31.0004',
    ),
  ];

  late int _selectedIndex;
  WebViewController? _controller;
  bool _loading = true;
  int _webViewKey = 0;
  Timer? _branchCycleTimer;
  final ScrollController _chipsScrollController = ScrollController();
  late AnimationController _progressController;
  late final List<GlobalKey> _chipKeys = List.generate(_branches.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _initController(_branches[_selectedIndex].embedUrl);
    _startBranchAutoCycle();
  }

  void _startBranchAutoCycle() {
    _branchCycleTimer?.cancel();
    _progressController.stop();
    _progressController.reset();
    _progressController.forward();

    _branchCycleTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      final nextIndex = (_selectedIndex + 1) % _branches.length;
      _selectBranch(nextIndex);
    });
  }

  @override
  void dispose() {
    _branchCycleTimer?.cancel();
    _chipsScrollController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _initController(String url) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(url));
  }

  void _scrollToSelectedChip(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_chipsScrollController.hasClients) return;
      final keyContext = _chipKeys[index].currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 500),
          alignment: 0.5,
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  void _selectBranch(int index) {
    if (_selectedIndex == index && _controller != null) return;
    setState(() {
      _selectedIndex = index;
      _loading = true;
      _webViewKey++;
      _controller = null;
    });
    _initController(_branches[index].embedUrl);
    _scrollToSelectedChip(index);
    _startBranchAutoCycle();
  }

  @override
  Widget build(BuildContext context) {
    final currentBranch = _branches[_selectedIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auto-Cycle Progress Line 🎯
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressController.value,
                  minHeight: 2.5,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.accentGold.withValues(alpha: 0.85),
                  ),
                );
              },
            ),

            // Card Padding Container for All Sides
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compact Header Section
                  Row(
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        color: AppColors.primaryBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'فروع الأكاديمية الرسمية 🗺️',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryBlue,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'اختر الفرع 📍',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Horizontal Branch Chips Bar
                  SingleChildScrollView(
                    controller: _chipsScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(_branches.length, (index) {
                        final branch = _branches[index];
                        final isSelected = _selectedIndex == index;

                        return Padding(
                          key: _chipKeys[index],
                          padding: const EdgeInsets.only(left: 6.0),
                          child: AnimatedScale(
                            scale: isSelected ? 1.03 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            child: ChoiceChip(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              avatar: Icon(
                                isSelected
                                    ? Icons.star_rounded
                                    : Icons.location_on_rounded,
                                size: 14,
                                color: isSelected
                                    ? AppColors.accentGold
                                    : AppColors.primaryBlue,
                              ),
                              label: Text(
                                '${branch.name} (${branch.city})',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : AppColors.textPrimary),
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primaryBlue,
                              backgroundColor: isDark
                                  ? const Color(0xFF334155)
                                  : Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.accentGold
                                      : Colors.transparent,
                                  width: isSelected ? 1.2 : 0,
                                ),
                              ),
                              onSelected: (_) => _selectBranch(index),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Ultra-Compact Map Frame (Height: 125px with padding)
                  Container(
                    height: 125,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Stack(
                          key: ValueKey('map_stack_$_webViewKey'),
                          children: [
                            if (_controller != null)
                              WebViewWidget(
                                key: ValueKey(_webViewKey),
                                controller: _controller!,
                              ),
                            if (_loading)
                              Container(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : Colors.grey[50],
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryBlue,
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'تحميل خريطة ${currentBranch.name}...',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
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
                  const SizedBox(height: 12),

                  // Compact Inline Address & Navigation Action Bar
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      key: ValueKey(currentBranch.id),
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.accentGold,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${currentBranch.name}: ${currentBranch.address}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            final uri = Uri.parse(currentBranch.googleMapsUrl);
                            if (!await launchUrl(uri,
                                mode: LaunchMode.externalApplication)) {
                              if (context.mounted) {
                                CustomSnackBar.show(
                                  context,
                                  message: 'تعذر فتح اللوكيشن',
                                  type: SnackBarType.error,
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4285F4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.directions_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'خرائط Google',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}


