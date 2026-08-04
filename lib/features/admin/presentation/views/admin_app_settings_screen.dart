import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/app_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snack_bar.dart';

class AdminAppSettingsScreen extends StatefulWidget {
  const AdminAppSettingsScreen({super.key});

  @override
  State<AdminAppSettingsScreen> createState() => _AdminAppSettingsScreenState();
}

class _AdminAppSettingsScreenState extends State<AdminAppSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // Controllers
  late TextEditingController _priceA1Ctrl;
  late TextEditingController _priceA2Ctrl;
  late TextEditingController _priceB1Ctrl;
  late TextEditingController _priceB2Ctrl;

  late TextEditingController _support1Ctrl;
  late TextEditingController _support2Ctrl;

  late TextEditingController _facebookCtrl;
  late TextEditingController _youtubeCtrl;
  late TextEditingController _instagramCtrl;
  late TextEditingController _tiktokCtrl;

  late TextEditingController _groupLinkA1Ctrl;
  late TextEditingController _groupLinkA2Ctrl;
  late TextEditingController _groupLinkB1Ctrl;
  late TextEditingController _groupLinkB2Ctrl;

  late TextEditingController _announcementCtrl;
  late TextEditingController _discountCtrl;
  bool _isAnnouncementActive = true;

  late TextEditingController _youtubeLiveCtrl;
  bool _isLiveActive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final settings = await AppSettingsService.loadSettings();
    setState(() {
      _priceA1Ctrl = TextEditingController(text: settings.priceA1);
      _priceA2Ctrl = TextEditingController(text: settings.priceA2);
      _priceB1Ctrl = TextEditingController(text: settings.priceB1);
      _priceB2Ctrl = TextEditingController(text: settings.priceB2);

      _support1Ctrl = TextEditingController(text: settings.supportNumber1);
      _support2Ctrl = TextEditingController(text: settings.supportNumber2);

      _facebookCtrl = TextEditingController(text: settings.facebookUrl);
      _youtubeCtrl = TextEditingController(text: settings.youtubeUrl);
      _instagramCtrl = TextEditingController(text: settings.instagramUrl);
      _tiktokCtrl = TextEditingController(text: settings.tiktokUrl);

      _groupLinkA1Ctrl = TextEditingController(text: settings.groupLinkA1);
      _groupLinkA2Ctrl = TextEditingController(text: settings.groupLinkA2);
      _groupLinkB1Ctrl = TextEditingController(text: settings.groupLinkB1);
      _groupLinkB2Ctrl = TextEditingController(text: settings.groupLinkB2);

      _announcementCtrl = TextEditingController(text: settings.announcementText);
      _discountCtrl = TextEditingController(text: settings.discountPercentage);
      _isAnnouncementActive = settings.isAnnouncementActive;

      _youtubeLiveCtrl = TextEditingController(text: settings.youtubeLiveUrl);
      _isLiveActive = settings.isLiveActive;

      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedSettings = AppSettingsModel(
      priceA1: _priceA1Ctrl.text.trim(),
      priceA2: _priceA2Ctrl.text.trim(),
      priceB1: _priceB1Ctrl.text.trim(),
      priceB2: _priceB2Ctrl.text.trim(),
      supportNumber1: _support1Ctrl.text.trim(),
      supportNumber2: _support2Ctrl.text.trim(),
      facebookUrl: _facebookCtrl.text.trim(),
      youtubeUrl: _youtubeCtrl.text.trim(),
      instagramUrl: _instagramCtrl.text.trim(),
      tiktokUrl: _tiktokCtrl.text.trim(),
      groupLinkA1: _groupLinkA1Ctrl.text.trim(),
      groupLinkA2: _groupLinkA2Ctrl.text.trim(),
      groupLinkB1: _groupLinkB1Ctrl.text.trim(),
      groupLinkB2: _groupLinkB2Ctrl.text.trim(),
      announcementText: _announcementCtrl.text.trim(),
      discountPercentage: _discountCtrl.text.trim(),
      isAnnouncementActive: _isAnnouncementActive,
      youtubeLiveUrl: _youtubeLiveCtrl.text.trim(),
      isLiveActive: _isLiveActive,
    );

    await AppSettingsService.saveSettings(updatedSettings);

    if (mounted) {
      CustomSnackBar.show(
        context,
        message: 'تم حفظ كافة الإعدادات والأسعار وروابط المجموعات بنجاح ✅',
        type: SnackBarType.success,
        title: 'تحديث النظام',
      );
    }
  }

  @override
  void dispose() {
    _priceA1Ctrl.dispose();
    _priceA2Ctrl.dispose();
    _priceB1Ctrl.dispose();
    _priceB2Ctrl.dispose();
    _support1Ctrl.dispose();
    _support2Ctrl.dispose();
    _facebookCtrl.dispose();
    _youtubeCtrl.dispose();
    _instagramCtrl.dispose();
    _tiktokCtrl.dispose();
    _groupLinkA1Ctrl.dispose();
    _groupLinkA2Ctrl.dispose();
    _groupLinkB1Ctrl.dispose();
    _groupLinkB2Ctrl.dispose();
    _announcementCtrl.dispose();
    _discountCtrl.dispose();
    _youtubeLiveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '⚙️ إعدادات التطبيق والأسعار',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlueDark,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ─── Course Prices Section ────────────────────────
                  _buildSectionCard(
                    context,
                    title: '🏷️ أسعار الكورسات والمستويات (EGP)',
                    isDark: isDark,
                    children: [
                      _buildTextField(
                        controller: _priceA1Ctrl,
                        label: 'سعر كورس A1',
                        icon: Icons.sell_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _priceA2Ctrl,
                        label: 'سعر كورس A2',
                        icon: Icons.sell_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _priceB1Ctrl,
                        label: 'سعر كورس B1',
                        icon: Icons.sell_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _priceB2Ctrl,
                        label: 'سعر كورس B2',
                        icon: Icons.sell_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── Support & WhatsApp Section ────────────────────
                  _buildSectionCard(
                    context,
                    title: '📞 أرقام الدعم الفني والواتساب',
                    isDark: isDark,
                    children: [
                      _buildTextField(
                        controller: _support1Ctrl,
                        label: 'رقم الواتساب الأساسي',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _support2Ctrl,
                        label: 'رقم الواتساب الاحتياطي',
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── Social Media Links Section ───────────────────
                  _buildSectionCard(
                    context,
                    title: '🌐 روابط التواصل الاجتماعي',
                    isDark: isDark,
                    children: [
                      _buildTextField(
                        controller: _facebookCtrl,
                        label: 'رابط فيسبوك (Facebook)',
                        icon: Icons.facebook_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _youtubeCtrl,
                        label: 'رابط يوتيوب (YouTube)',
                        icon: Icons.play_circle_fill_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _instagramCtrl,
                        label: 'رابط إنستجرام (Instagram)',
                        icon: Icons.camera_alt_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _tiktokCtrl,
                        label: 'رابط تيك توك (TikTok)',
                        icon: Icons.music_note_rounded,
                      ),
                    ],
                  ),
                  _buildSectionCard(
                    context,
                    title: '💬 روابط جروبات التليجرام/الواتساب المخصصة للمستويات',
                    isDark: isDark,
                    children: [
                      _buildTextField(
                        controller: _groupLinkA1Ctrl,
                        label: 'رابط جروب كورس A1 الخاص',
                        icon: Icons.send_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _groupLinkA2Ctrl,
                        label: 'رابط جروب كورس A2 الخاص',
                        icon: Icons.send_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _groupLinkB1Ctrl,
                        label: 'رابط جروب كورس B1 الخاص',
                        icon: Icons.send_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _groupLinkB2Ctrl,
                        label: 'رابط جروب كورس B2 الخاص',
                        icon: Icons.send_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    context,
                    title: '📢 شريط الإعلانات والخصومات بالواجهة الرئيسية',
                    isDark: isDark,
                    children: [
                      SwitchListTile(
                        tileColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        value: _isAnnouncementActive,
                        onChanged: (val) => setState(() => _isAnnouncementActive = val),
                        title: Text(
                          'تفعيل شريط الإعلانات والخصومات بالشاشة الرئيسية',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(
                          _isAnnouncementActive ? '🟢 الإعلان ظاهِر حالياً للطلاب' : '🔴 الإعلان مخفِي حالياً',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: _isAnnouncementActive ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.primaryBlue,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _discountCtrl,
                        label: 'نسبة الخصم المعلنة (مثال: 25% أو 30%)',
                        icon: Icons.percent_rounded,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'اختيار نسبة سريعة: ',
                            style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 6,
                            children: ['15%', '20%', '25%', '30%', '50%'].map((perc) {
                              return ActionChip(
                                label: Text(perc, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                onPressed: () {
                                  setState(() {
                                    _discountCtrl.text = perc;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _announcementCtrl,
                        label: 'نص الإعلان أو التنويه الرئيسي',
                        icon: Icons.campaign_rounded,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '✨ جمل رايقة وجذابة للاقتباس فوراً (اضغط لاختيار الجملة):',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPresetChip(
                            '🚀 انطلاقة رايقة',
                            '🚀 انطلاقة ألمانية رايقة مع Herr خالد! خصم حصري ${_discountCtrl.text.isNotEmpty ? _discountCtrl.text : "25%"} لجميع مستويات أكاديمية Deutsch Welt 🇩🇪🎓',
                          ),
                          _buildPresetChip(
                            '⚡ تحدث كالبلبل',
                            '⚡ فرصتك الأقوى للتحدث بالألمانية كالبلبل! خصم خاص ${_discountCtrl.text.isNotEmpty ? _discountCtrl.text : "25%"} لفترة محدودة جداً 🇩🇪✨',
                          ),
                          _buildPresetChip(
                            '🎓 السفر والعمل',
                            '🎓 احترف اللغة الألمانية وافتح أبواب السفر والعمل! خصم ${_discountCtrl.text.isNotEmpty ? _discountCtrl.text : "25%"} على كافة المستويات 🇩🇪🔥',
                          ),
                          _buildPresetChip(
                            '💎 العرض الذهبي',
                            '💎 العرض الذهبي من Herr خالد الحلواني! استمتع بخصم ${_discountCtrl.text.isNotEmpty ? _discountCtrl.text : "25%"} عند التسجيل اليوم 🎁🌟',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── YouTube Live Broadcast Section ──────────────
                  _buildSectionCard(
                    context,
                    title: '🔴 البث المباشر (YouTube Live Broadcast)',
                    isDark: isDark,
                    children: [
                      SwitchListTile(
                        tileColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        value: _isLiveActive,
                        onChanged: (val) => setState(() => _isLiveActive = val),
                        title: Text(
                          'إظهار تنبيه "بث مباشر الآن على يوتيوب 🔴"',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        activeThumbColor: Colors.white,
                        activeTrackColor: Colors.redAccent,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _youtubeLiveCtrl,
                        label: 'رابط البث المباشر على YouTube',
                        icon: Icons.live_tv_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _saveData,
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    label: Text(
                      'حفظ التغييرات الآن 💾',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال البيانات المطلوب تعديلها';
        }
        return null;
      },
    );
  }

  Widget _buildPresetChip(String label, String fullText) {
    return ActionChip(
      avatar: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primaryBlue),
      label: Text(label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold)),
      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.08),
      side: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      onPressed: () {
        setState(() {
          _announcementCtrl.text = fullText;
        });
      },
    );
  }
}
