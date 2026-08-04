import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CouponModel {
  final String id;
  final String code;
  final double discountValue;
  final bool isPercentage;
  final int maxUsers;
  final int usedCount;
  final int expiryDays;
  final DateTime createdAt;
  final String targetCourse;
  final bool isActive;

  // Single-use security features
  final bool singleUsePerStudent;
  final String? targetStudentPhone;
  final List<String> redeemedUserIds;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.isPercentage,
    required this.maxUsers,
    this.usedCount = 0,
    required this.expiryDays,
    required this.createdAt,
    required this.targetCourse,
    this.isActive = true,
    this.singleUsePerStudent = true,
    this.targetStudentPhone,
    List<String>? redeemedUserIds,
  }) : redeemedUserIds = redeemedUserIds ?? [];

  DateTime get expiryDate => createdAt.add(Duration(days: expiryDays));
  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isFullyUsed => usedCount >= maxUsers;

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      code: json['code'] ?? '',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      isPercentage: json['is_percentage'] ?? true,
      maxUsers: json['max_users'] ?? 50,
      usedCount: json['used_count'] ?? 0,
      expiryDays: json['expiry_days'] ?? 7,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      targetCourse: json['target_course'] ?? 'جميع الكورسات والكتب',
      isActive: json['is_active'] ?? true,
      singleUsePerStudent: json['single_use_per_student'] ?? true,
      targetStudentPhone: json['target_student_phone'],
      redeemedUserIds: (json['redeemed_user_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'discount_value': discountValue,
        'is_percentage': isPercentage,
        'max_users': maxUsers,
        'used_count': usedCount,
        'expiry_days': expiryDays,
        'created_at': createdAt.toIso8601String(),
        'target_course': targetCourse,
        'is_active': isActive,
        'single_use_per_student': singleUsePerStudent,
        'target_student_phone': targetStudentPhone,
        'redeemed_user_ids': redeemedUserIds,
      };

  CouponModel copyWith({int? usedCount, List<String>? redeemedUserIds}) {
    return CouponModel(
      id: id,
      code: code,
      discountValue: discountValue,
      isPercentage: isPercentage,
      maxUsers: maxUsers,
      usedCount: usedCount ?? this.usedCount,
      expiryDays: expiryDays,
      createdAt: createdAt,
      targetCourse: targetCourse,
      isActive: isActive,
      singleUsePerStudent: singleUsePerStudent,
      targetStudentPhone: targetStudentPhone,
      redeemedUserIds: redeemedUserIds ?? this.redeemedUserIds,
    );
  }
}

class CouponValidationResult {
  final bool isValid;
  final String message;
  final CouponModel? coupon;
  final double discountedPrice;
  final double discountAmount;

  CouponValidationResult({
    required this.isValid,
    required this.message,
    this.coupon,
    this.discountedPrice = 0,
    this.discountAmount = 0,
  });
}

class CouponService {
  static const String _key = 'deutsch_welt_coupons_v2';

  static Future<List<CouponModel>> getCoupons() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null || data.isEmpty) {
      final defaultCoupons = [
        CouponModel(
          id: '1',
          code: 'DEUTSCH20',
          discountValue: 20,
          isPercentage: true,
          maxUsers: 50,
          usedCount: 3,
          expiryDays: 14,
          createdAt: DateTime.now(),
          targetCourse: 'جميع الكورسات والكتب',
          singleUsePerStudent: true,
        ),
        CouponModel(
          id: '2',
          code: 'HERR100',
          discountValue: 100,
          isPercentage: false,
          maxUsers: 30,
          usedCount: 5,
          expiryDays: 7,
          createdAt: DateTime.now(),
          targetCourse: 'جميع الكورسات والكتب',
          singleUsePerStudent: true,
        ),
      ];
      await saveCoupons(defaultCoupons);
      return defaultCoupons;
    }

    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => CouponModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCoupons(List<CouponModel> coupons) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(coupons.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<void> addCoupon(CouponModel newCoupon) async {
    final coupons = await getCoupons();
    coupons.insert(0, newCoupon);
    await saveCoupons(coupons);
  }

  static Future<CouponValidationResult> applyCoupon({
    required String inputCode,
    required double originalPrice,
    required String courseName,
    String? studentPhone,
  }) async {
    final cleanCode = inputCode.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      return CouponValidationResult(
        isValid: false,
        message: 'يرجى كتابة كود الخصم أولاً',
      );
    }

    final coupons = await getCoupons();
    final matchingIndex = coupons.indexWhere(
        (c) => c.code.toUpperCase() == cleanCode && c.isActive);

    if (matchingIndex == -1) {
      return CouponValidationResult(
        isValid: false,
        message: 'كود الخصم غير صحيح أو غير موجود!',
      );
    }

    final coupon = coupons[matchingIndex];

    if (coupon.isExpired) {
      return CouponValidationResult(
        isValid: false,
        message: 'عذراً، كود الخصم هذا انتهت مدة صلاحيته!',
      );
    }

    if (coupon.isFullyUsed) {
      return CouponValidationResult(
        isValid: false,
        message: 'عذراً، اكتمل عدد الطلاب المسموح لهم باستخدام هذا الكوبون!',
      );
    }

    // 🔒 Check single-use per student / user phone
    if (coupon.singleUsePerStudent && studentPhone != null && studentPhone.isNotEmpty) {
      if (coupon.redeemedUserIds.contains(studentPhone)) {
        return CouponValidationResult(
          isValid: false,
          message: 'عذراً، لقد قمت باستخدام هذا الكوبون سابقاً! الكوبون مخصص للاستخدام لمرة واحدة فقط لكل حساب طالب 🚫',
        );
      }
    }

    // 🔒 Check dedicated student target phone number
    if (coupon.targetStudentPhone != null && coupon.targetStudentPhone!.trim().isNotEmpty) {
      final targetClean = coupon.targetStudentPhone!.trim().replaceAll(RegExp(r'[^\d]'), '');
      final currentClean = (studentPhone ?? '').trim().replaceAll(RegExp(r'[^\d]'), '');
      if (currentClean.isEmpty || !targetClean.contains(currentClean)) {
        return CouponValidationResult(
          isValid: false,
          message: 'هذا الكوبون مخصص حصرياً لطالب محدد برقم هاتف معين 🚫',
        );
      }
    }

    // Check target course matching
    if (coupon.targetCourse != 'جميع الكورسات والكتب') {
      final target = coupon.targetCourse.toLowerCase();
      final current = courseName.toLowerCase();
      if (!current.contains(target) && !target.contains(current)) {
        return CouponValidationResult(
          isValid: false,
          message: 'هذا الكوبون مخصص فقط لـ (${coupon.targetCourse})',
        );
      }
    }

    // Calculate discount amount
    double discountAmount = 0.0;
    if (coupon.isPercentage) {
      discountAmount = (originalPrice * coupon.discountValue) / 100.0;
    } else {
      discountAmount = coupon.discountValue;
    }

    if (discountAmount > originalPrice) {
      discountAmount = originalPrice;
    }

    final finalPrice = originalPrice - discountAmount;

    return CouponValidationResult(
      isValid: true,
      message: 'تم تفعيل كود الخصم بنجاح! 🎉',
      coupon: coupon,
      discountedPrice: finalPrice,
      discountAmount: discountAmount,
    );
  }

  static Future<void> incrementCouponUsage(String code, {String? studentPhone}) async {
    final coupons = await getCoupons();
    final index = coupons.indexWhere((c) => c.code.toUpperCase() == code.toUpperCase());
    if (index != -1) {
      final coupon = coupons[index];
      final updatedRedeemed = List<String>.from(coupon.redeemedUserIds);
      if (studentPhone != null && studentPhone.isNotEmpty && !updatedRedeemed.contains(studentPhone)) {
        updatedRedeemed.add(studentPhone);
      }
      coupons[index] = coupon.copyWith(
        usedCount: coupon.usedCount + 1,
        redeemedUserIds: updatedRedeemed,
      );
      await saveCoupons(coupons);
    }
  }
}
