import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsModel {
  // Course Prices & Details
  final String priceA1;
  final String priceA2;
  final String priceB1;
  final String priceB2;

  // Contact Numbers
  final String supportNumber1;
  final String supportNumber2;

  // Social Links
  final String facebookUrl;
  final String youtubeUrl;
  final String instagramUrl;
  final String tiktokUrl;

  // Course Telegram/WhatsApp Group Links
  final String groupLinkA1;
  final String groupLinkA2;
  final String groupLinkB1;
  final String groupLinkB2;

  // Announcement Banner & YouTube Live Broadcast
  final String announcementText;
  final String discountPercentage;
  final bool isAnnouncementActive;
  final String youtubeLiveUrl;
  final bool isLiveActive;

  const AppSettingsModel({
    required this.priceA1,
    required this.priceA2,
    required this.priceB1,
    required this.priceB2,
    required this.supportNumber1,
    required this.supportNumber2,
    required this.facebookUrl,
    required this.youtubeUrl,
    required this.instagramUrl,
    required this.tiktokUrl,
    required this.groupLinkA1,
    required this.groupLinkA2,
    required this.groupLinkB1,
    required this.groupLinkB2,
    required this.announcementText,
    required this.discountPercentage,
    required this.isAnnouncementActive,
    required this.youtubeLiveUrl,
    required this.isLiveActive,
  });

  factory AppSettingsModel.defaultSettings() {
    return const AppSettingsModel(
      priceA1: '1500',
      priceA2: '1500',
      priceB1: '1500',
      priceB2: '1500',
      supportNumber1: '01144151673',
      supportNumber2: '01055287454',
      facebookUrl: 'https://www.facebook.com/share/1Csuf2zQJh/',
      youtubeUrl: 'https://youtube.com/@gatewaytogermany',
      instagramUrl: 'https://www.instagram.com/khaledelhalwany',
      tiktokUrl: 'https://www.tiktok.com/@khaled.elhalawany8',
      groupLinkA1: 'https://t.me/DeutschWelt_A1',
      groupLinkA2: 'https://t.me/DeutschWelt_A2',
      groupLinkB1: 'https://t.me/DeutschWelt_B1',
      groupLinkB2: 'https://t.me/DeutschWelt_B2',
      announcementText: '🔥 انطلاقة جديدة مع Herr خالد! خصم حصري لجميع مستويات أكاديمية Deutsch Welt 🎓🇩🇪',
      discountPercentage: '25%',
      isAnnouncementActive: true,
      youtubeLiveUrl: 'https://youtube.com/@gatewaytogermany/live',
      isLiveActive: false,
    );
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      priceA1: json['price_a1'] ?? '1500',
      priceA2: json['price_a2'] ?? '1500',
      priceB1: json['price_b1'] ?? '1500',
      priceB2: json['price_b2'] ?? '1500',
      supportNumber1: json['support_number1'] ?? '01144151673',
      supportNumber2: json['support_number2'] ?? '01055287454',
      facebookUrl: json['facebook_url'] ?? 'https://www.facebook.com/share/1Csuf2zQJh/',
      youtubeUrl: json['youtube_url'] ?? 'https://youtube.com/@gatewaytogermany',
      instagramUrl: json['instagram_url'] ?? 'https://www.instagram.com/khaledelhalwany',
      tiktokUrl: json['tiktok_url'] ?? 'https://www.tiktok.com/@khaled.elhalawany8',
      groupLinkA1: json['group_link_a1'] ?? 'https://t.me/DeutschWelt_A1',
      groupLinkA2: json['group_link_a2'] ?? 'https://t.me/DeutschWelt_A2',
      groupLinkB1: json['group_link_b1'] ?? 'https://t.me/DeutschWelt_B1',
      groupLinkB2: json['group_link_b2'] ?? 'https://t.me/DeutschWelt_B2',
      announcementText: json['announcement_text'] ?? '🔥 انطلاقة جديدة مع Herr خالد! خصم حصري لجميع مستويات أكاديمية Deutsch Welt 🎓🇩🇪',
      discountPercentage: json['discount_percentage'] ?? '25%',
      isAnnouncementActive: json['is_announcement_active'] ?? true,
      youtubeLiveUrl: json['youtube_live_url'] ?? 'https://youtube.com/@gatewaytogermany/live',
      isLiveActive: json['is_live_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'price_a1': priceA1,
        'price_a2': priceA2,
        'price_b1': priceB1,
        'price_b2': priceB2,
        'support_number1': supportNumber1,
        'support_number2': supportNumber2,
        'facebook_url': facebookUrl,
        'youtube_url': youtubeUrl,
        'instagram_url': instagramUrl,
        'tiktok_url': tiktokUrl,
        'group_link_a1': groupLinkA1,
        'group_link_a2': groupLinkA2,
        'group_link_b1': groupLinkB1,
        'group_link_b2': groupLinkB2,
        'announcement_text': announcementText,
        'discount_percentage': discountPercentage,
        'is_announcement_active': isAnnouncementActive,
        'youtube_live_url': youtubeLiveUrl,
        'is_live_active': isLiveActive,
      };
}

class AppSettingsService {
  static const String _key = 'app_custom_settings';

  static Future<AppSettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str != null) {
      try {
        return AppSettingsModel.fromJson(jsonDecode(str));
      } catch (_) {}
    }
    return AppSettingsModel.defaultSettings();
  }

  static Future<void> saveSettings(AppSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
