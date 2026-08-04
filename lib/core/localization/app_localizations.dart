import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // General
      'app_title': 'دويتش فيلت',
      'login': 'تسجيل الدخول',
      'signup': 'حساب جديد',
      'logout': 'تسجيل الخروج',
      'home': 'الرئيسية',
      'courses': 'الكورسات المتاحة',
      'profile': 'الملف الشخصي',
      'who_is_herr_khaled': 'من هو Herr / خالد الحلواني؟',
      'privacy_policy': 'سياسة الخصوصية',
      'academy_privacy_policy': 'سياسة الخصوصية الخاصة بالأكاديمية',
      'privacy_policy_desc': 'نحن في أكاديمية دويتش فيلت نلتزم بحماية خصوصيتك وبياناتك الشخصية. هذه الوثيقة توضح كيفية تعاملنا مع المعلومات التي تقدمها لنا لضمان تجربة تعليمية آمنة ومتميزة.',
      'hello': 'أهلاً',
      'new_visitor': 'زائر جديد',
      'welcome_academy': 'أهلاً بك في أكاديميتنا',
      'close': 'إغلاق',
      'no_internet': 'لا يوجد اتصال بالإنترنت',
      
      // Home View Slider
      'slider_title_1': 'مرحباً بك في أكاديمية دويتش فيلت DEUTSCH WELT',
      'slider_subtitle_1': 'تعلم الألمانية بأسلوب عصري وحديث مع Herr / خالد الحلواني',
      'slider_title_2': 'سجل الآن في كورساتنا',
      'slider_subtitle_2': 'ابنِ مستقبلك المهني والأكاديمي في ألمانيا بخطوات ثابتة',
      'slider_title_3': 'متابعة مستمرة وتقييم دائم',
      'slider_subtitle_3': 'نضمن لك التميز من خلال المتابعة اليومية والامتحانات الدورية',
      
      // Home Features
      'why_academy': 'لماذا أكاديمية دويتش فيلت؟',
      'daily_followup': 'متابعة\nيومية',
      'exam_preparation': 'تأهيل\nGoethe & Telc',
      'technical_support': 'دعم فني\n24/7',
      'direct_mentor': 'مباشر معك',
      'high_success': 'درجات نهائية',
      'always_available': 'متاح دائماً',
      'preparing_content': 'جاري تحضير المحتوى لك... 🚀',
      'daily_followup_desc': 'نظام متابعة يومي مكثف يشمل تصحيح الواجبات والتواصل المباشر مع المحاضر لضمان أفضل نتيجة واستيعاب.',
      'exam_prep_desc': 'تأهيل كامل وشامل لاجتياز امتحانات جوته وتيلك الدولية من المستوى A1 وحتى B2 بأعلى النسبة والدرجات.',
      'tech_support_desc': 'فريق دعم فني متواجد على مدار الساعة لمساعدتك في أي استفسار أو مشكلة تقنية أثناء رحلتك التعليمية.',
      'explore_courses': 'استكشف الكورسات والمستويات',
      'explore_books': 'تصفح كتب الأكاديمية',
      'contact_whatsapp_now': 'تواصل عبر واتساب الآن 📲',
      
      // Home Instructor
      'who_is_instructor': 'من هو Herr / خالد الحلواني؟',
      'instructor_desc': 'تعرف على مسيرة Herr / خالد الحلواني المهنية وخبرته التي تمتد لأكثر من 10 سنوات في تدريس اللغة الألمانية.',
      'view_cv': 'عرض الـ CV كامل',
      
      // Home Course Details
      'available_courses': 'الكورسات المتاحة',
      'course_level': 'كورس المستوى',
      'currency': 'ج.م',
      'lessons_count': 'درس',
      'weeks_count': 'أسابيع',
      'journey_welcome': 'أهلاً بك في رحلة تعلم الألمانية! 🇩🇪',
      'access_denied': 'عفواً',
      'access_denied_desc': 'لا يمكنك الدخول إلى هذا الكورس. يجب عليك التسجيل أولاً، ثم دفع الرسوم وانتظار موافقة الإدارة.',
      'register_now_btn': 'تسجيل الآن',
      
      // Logout Dialog
      'logout_dialog_title': 'تسجيل الخروج',
      'logout_dialog_body': 'هل أنت متأكد أنك تريد\nتسجيل الخروج من حسابك؟',
      'cancel_btn': 'لا، ابقى',
      'confirm_btn': 'نعم، اخرج',
      'logged_out': 'تم الخروج',
      'goodbye': 'إلى اللقاء! 👋',
      'language_changed_title': 'تم تغيير اللغة',
      'language_changed_desc': 'تم تغيير لغة التطبيق بنجاح',
      'login_success_title': 'تم تسجيل الدخول!',
      'login_success_body': 'مرحباً بك مجدداً يا [name] 👋',
      'register_success_title': 'تم التسجيل بنجاح!',
      'register_success_body': 'أهلاً بك في أكاديميتنا يا [name] 🎉',
      
      // Languages
      'select_language': 'اختر اللغة',
      'arabic': 'العربية',
      'german': 'الألمانية',

      // Footer
      'academy_desc': 'أكاديمية دويتش فيلت، خيارك الأول للوصول للدرجة النهائية في اللغة الألمانية.',
      'quick_links': 'روابط سريعة',
      'technical_support_title': 'الدعم الفني والاشتراكات',
      'all_rights_reserved': 'جميع الحقوق محفوظة © 2026 | Deutsch Welt',
      'developer_credits': 'تطوير وبرمجة: م / إبراهيم سمير',
      
      // Testimonials & FAQ
      'our_students_opinions': 'آَرَاءُ طُلَّابِ Deutsch Welt Akademie',
      'reviews_section_title': 'آَرَاءُ طُلَّابِ Deutsch Welt Akademie 🌟',
      'reviews_section_subtitle': 'رسائل حقيقية وموثقة من طلاب أكاديمية Deutsch Welt مع Herr خالد الحلواني',
      'tap_to_zoom_hint': 'اضغط لتكبير الصورة لقراءة التجربة 🔍',
      'lightbox_quality_hint': 'جودة عالية • اسحب للتكبير 🔍',
      'image_not_available': 'الصورة غير مجهزة',
      'pause_autoplay': 'إيقاف التمرير التلقائي',
      'start_autoplay': 'تشغيل التمرير التلقائي',
      'student_title_1': 'طالب في المستوى A1',
      'student_title_2': 'طالبة في أكاديمية Deutsch Welt',
      'student_title_3': 'طالب في المستوى B1',
      'student_title_4': 'طالبة في كورس المحادثة',
      'student_title_5': 'طالب في المستوى A2',
      'student_title_6': 'طالبة في المستوى B2',
      'excellent_student': 'طالب متميز',
      'excellent_student_desc': 'بفضل الله ثم Herr / خالد الحلواني، نجحت في امتحان B1 من أول مرة! الشرح مبسط والمتابعة ممتازة جداً.',
      'faq_title': 'الأسئلة الشائعة',
      'faq_q1': 'هل أحتاج لمعرفة مسبقة بالألمانية؟',
      'faq_a1': 'لا، كورس A1 يبدأ معك من الصفر تماماً.',
      'faq_q2': 'كيف يتم الدفع؟',
      'faq_a2': 'يمكنك الدفع عبر فودافون كاش، انستا باي، أو التحويل البنكي.',
      'faq_q3': 'هل الشهادة معتمدة؟',
      'faq_a3': 'نحن نؤهلك لاجتياز الامتحانات المعتمدة دولياً.',
      
      // Admin Drawer
      'admin_dashboard': 'لوحة التحكم',
      'student_management': 'إدارة الطلاب',
      'course_management': 'إدارة الكورسات',
      'earnings_collection': 'الأرباح والتحصيل',
      'send_alerts': 'إرسال تنبيهات',
      'settings': 'الإعدادات',
      'system_admin': 'مدير النظام',
      'deutsch_welt_academy': 'أكاديمية دويتش فيلت',
      'logout_success': 'تم تسجيل الخروج بنجاح',

      // Admin Student Edit
      'first_name': 'الاسم الأول',
      'last_name': 'اسم العائلة',
      'email': 'البريد الإلكتروني',
      'phone': 'رقم الهاتف',
      'field_required': 'هذا الحقل مطلوب',
      'invalid_email': 'بريد إلكتروني غير صالح',
      'active_student': 'طالب نشط',
      'save_changes': 'حفظ التغييرات',
      'add_student': 'إضافة طالب',
      'edit_student': 'تعديل بيانات الطالب',
      'student_added': 'تم إضافة الطالب بنجاح ✅',
      'student_updated': 'تم تحديث بيانات الطالب بنجاح ✅',
      'confirm_delete': 'تأكيد الحذف',
      'delete_student_prompt': 'هل أنت متأكد من حذف هذا الطالب؟',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'student_deleted': 'تم حذف الطالب بنجاح',
      'no_students_found': 'لا يوجد طلاب حالياً',

      // Book Section
      'book_title': 'كتاب Herr / خالد الحلواني',
      'pdf_ebook_pages': 'كتاب إلكتروني PDF • [pages] صفحة',
      'current_price': 'السعر الحالي',
      'pdf_preview': 'معاينة PDF',
      'about_book': 'عن الكتاب',
      'why_book_special': 'لماذا هذا الكتاب مميز؟',
      'order_book_whatsapp': 'اطلب الكتاب الآن عبر واتساب',
      'currently_unavailable': 'غير متاح حالياً',
      'book_preview_title': 'معاينة الكتاب',
      'book_preview_coming_soon': 'معاينة الكتاب ستكون متاحة قريباً.\nللحصول على نسختك اضغط "اطلب الآن عبر واتساب".',
      'login_required_title': 'يجب تسجيل الدخول',
      'login_required_desc': 'سجل دخولك أولاً لطلب الكتاب.',
      'student_role': 'طالب',
      'not_specified': 'لم يُذكر',
      'cannot_open_whatsapp': 'لا يمكن فتح واتساب حالياً',
      'cannot_open_file': 'لا يمكن فتح الملف',
      'ok': 'حسناً',
      'instructor_book_quote': '"هذا الكتاب خلاصة كل ما تعلمته في تدريس الألمانية، صممته ليكون رفيقك في رحلتك كاملةً"',
      'order_confirmation_title': 'تأكيد طلب الشراء',
      'order_confirmation_subtitle': 'قم بتحويل المبلغ وسنقوم بتفعيل الكتاب وتوفير رابط الـ PDF فوراً 🚀',
      'transfer_instructions': 'تفاصيل تحويل المبلغ:',
      'vodafone_cash_number': 'رقم فودافون كاش / انستا باي:',
      'amount_to_transfer': 'المبلغ المطلوب تحويله:',
      'copy_number': 'نسخ الرقم',
      'number_copied': 'تم نسخ رقم تحويل فودافون كاش بنجاح 📋',
      'whatsapp_transfer_note': 'بعد التحويل، اضغط الزر بالأسفل للانتقال إلى واتساب وإرسال صورة التحويل (الاسكرين شوت) لتسهيل تفعيل حسابك مباشرة.',
      'confirm_and_open_whatsapp': 'تأكيد وإرسال عبر واتساب 📲',
      'payment_method_title': 'طريقة الدفع وإتمام الطلب',
      'book_price_label': 'سعر الكتاب: [price] جنيه',
      'select_payment_method': 'الرجاء اختيار طريقة الدفع المناسبة لك:',
      'vodafone_cash': 'فودافون كاش',
      'instapay': 'انستا باي (InstaPay)',
      'bank_transfer': 'تحويل بنكي direct',
      'coming_soon': 'قريباً ⏳',
      'payment_note': '💡 بعد إتمام عملية التحويل، يرجى حفظ "لقطة شاشة" (Screenshot) للتحويل والضغط على الزر بالأسفل لإرسالها وتأكيد الطلب.',
      'send_transfer': 'إرسال التحويل',

      // Profile Section
      'account_status': 'حالة الحساب',
      'active_status': 'نشط ✅',
      'no_phone': 'لا يوجد رقم هاتف',
      'user_fallback': 'المستخدم',
      'edit_profile': 'تعديل البيانات',
      'edit_personal_info': 'تعديل البيانات الشخصية',
      'save_edits': 'حفظ التعديلات',
      'change_password': 'تغيير كلمة المرور',
      'current_password': 'كلمة المرور الحالية',
      'new_password': 'كلمة المرور الجديدة',
      'confirm_new_password': 'تأكيد كلمة المرور الجديدة',
      'update_password': 'تحديث كلمة المرور',
      'update_success': 'تم تحديث بياناتك بنجاح! 🎉',
      'update_failed': 'عذراً، فشل تحديث البيانات',
      'password_change_success': 'تم تغيير كلمة المرور بنجاح! 🎉',
      'password_change_failed': 'عذراً، فشل تغيير كلمة المرور',
      'passwords_dont_match': 'كلمتا المرور غير متطابقتان',
      'password_min_length': 'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
      'dark_mode': 'الوضع الداكن (Dark Mode)',
      'light_mode': 'الوضع الفاتح (Light Mode)',
    },
    'de': {
      // General
      'app_title': 'Deutsch Welt',
      'login': 'Einloggen',
      'signup': 'Registrieren',
      'logout': 'Ausloggen',
      'home': 'Startseite',
      'courses': 'Verfügbare Kurse',
      'profile': 'Profil',
      'who_is_herr_khaled': 'Wer ist Herr Khaled?',
      'privacy_policy': 'Datenschutzrichtlinie',
      'academy_privacy_policy': 'Datenschutzrichtlinie der Akademie',
      'privacy_policy_desc': 'Bei der Deutsch Welt Akademie verpflichten wir uns zum Schutz Ihrer Privatsphäre und Ihrer persönlichen Daten. Dieses Dokument erläutert, wie wir mit den von Ihnen bereitgestellten Informationen umgehen, um ein sicheres und hervorragendes Lernerlebnis zu gewährleisten.',
      'hello': 'Hallo',
      'new_visitor': 'Neuer Besucher',
      'welcome_academy': 'Willkommen in der Akademie',
      'close': 'Schließen',
      'no_internet': 'Keine Internetverbindung',
      
      // Home View Slider
      'slider_title_1': 'Willkommen bei der Deutsch Welt Akademie',
      'slider_subtitle_1': 'Lernen Sie Deutsch auf moderne Weise mit Herrn Khaled Al-Halawani',
      'slider_title_2': 'Registrieren Sie sich für unsere Kurse',
      'slider_subtitle_2': 'Bauen Sie Ihre Karriere und akademische Zukunft in Deutschland auf',
      'slider_title_3': 'Kontinuierliche Betreuung und Prüfungen',
      'slider_subtitle_3': 'Erfolg garantiert durch tägliche Betreuung und regelmäßige Prüfungen',
      
      // Home Features
      'why_academy': 'Warum die Deutsch Welt Akademie?',
      'daily_followup': 'Tägliche\nBetreuung',
      'exam_preparation': 'Goethe & Telc\nVorbereitung',
      'technical_support': 'Technischer\nSupport 24/7',
      'direct_mentor': 'Direkt & Aktiv',
      'high_success': 'Hohe Erfolgsquote',
      'always_available': 'Immer erreichbar',
      'preparing_content': 'Inhalt wird vorbereitet... 🚀',
      'daily_followup_desc': 'Intensives tägliches Betreuungssystem mit Hausaufgabenkorrektur und direktem Kontakt mit dem Dozenten für optimale Ergebnisse.',
      'exam_prep_desc': 'Vollständige und umfassende Vorbereitung auf die internationalen Goethe- und Telc-Prüfungen von A1 bis B2.',
      'tech_support_desc': 'Ein rund um die Uhr verfügbares technisches Support-Team, das Ihnen bei allen Fragen oder technischen Problemen hilft.',
      'explore_courses': 'Kurse & Niveaus erkunden',
      'explore_books': 'Akademie-Bücher durchsuchen',
      'contact_whatsapp_now': 'Jetzt per WhatsApp kontaktieren 📲',
      
      // Home Instructor
      'who_is_instructor': 'Wer ist Herr Khaled Al-Halawani?',
      'instructor_desc': 'Erfahren Sie mehr über die Karriere und die über 10-jährige Erfahrung von Herrn Khaled im Unterrichten von Deutsch.',
      'view_cv': 'Vollständigen Lebenslauf anzeigen',
      
      // Home Course Details
      'available_courses': 'Verfügbare Kurse',
      'course_level': 'Kurs Niveau',
      'currency': 'EGP',
      'lessons_count': 'Lektionen',
      'weeks_count': 'Wochen',
      'journey_welcome': 'Willkommen auf Ihrer Deutsch-Lernreise! 🇩🇪',
      'access_denied': 'Zugriff verweigert',
      'access_denied_desc': 'Sie können nicht auf diesen Kurs zugreifen. Sie müssen sich zuerst registrieren, die Gebühren bezahlen und auf die Genehmigung warten.',
      'register_now_btn': 'Jetzt registrieren',
      
      // Logout Dialog
      'logout_dialog_title': 'Ausloggen',
      'logout_dialog_body': 'Sind Sie sicher, dass Sie sich von Ihrem Konto abmelden möchten?',
      'cancel_btn': 'Nein, bleiben',
      'confirm_btn': 'Ja, ausloggen',
      'logged_out': 'Abgemeldet',
      'goodbye': 'Auf Wiedersehen! 👋',
      'language_changed_title': 'Sprache geändert',
      'language_changed_desc': 'Die App-Sprache wurde erfolgreich geändert',
      'login_success_title': 'Erfolgreich angemeldet!',
      'login_success_body': 'Willkommen zurück, [name] 👋',
      'register_success_title': 'Erfolgreich registriert!',
      'register_success_body': 'Willkommen in unserer Akademie, [name] 🎉',
      
      // Languages
      'select_language': 'Sprache auswählen',
      'arabic': 'Arabisch',
      'german': 'Deutsch',

      // Footer
      'academy_desc': 'Deutsch Welt Akademie, Ihre erste Wahl, um Höchstnoten in Deutsch zu erreichen.',
      'quick_links': 'Schnellzugriff',
      'technical_support_title': 'Technischer Support & Abonnements',
      'all_rights_reserved': 'Alle Rechte vorbehalten © 2026 | Deutsch Welt',
      'developer_credits': 'Entwicklung & Design: Eng. Ebrahim Samir',
      
      // Testimonials & FAQ
      'our_students_opinions': 'Meinungen der Deutsch Welt Schüler',
      'reviews_section_title': 'Meinungen der Deutsch Welt Schüler 🌟',
      'reviews_section_subtitle': 'Echte und verifizierte Nachrichten von Schülern der Deutsch Welt Akademie mit Herr Khaled Al-Halawani',
      'tap_to_zoom_hint': 'Tippen zum Vergrößern 🔍',
      'lightbox_quality_hint': 'Hohe Qualität • Zum Zoomen ziehen 🔍',
      'image_not_available': 'Bild nicht verfügbar',
      'pause_autoplay': 'Automatische Wiedergabe pausieren',
      'start_autoplay': 'Automatische Wiedergabe starten',
      'student_title_1': 'Schüler im Niveau A1',
      'student_title_2': 'Schülerin in der Deutsch Welt Akademie',
      'student_title_3': 'Schüler im Niveau B1',
      'student_title_4': 'Schülerin im Konversationskurs',
      'student_title_5': 'Schüler im Niveau A2',
      'student_title_6': 'Schülerin im Niveau B2',
      'excellent_student': 'Hervorragender Schüler',
      'excellent_student_desc': 'Gott sei Dank und Herrn Khaled habe ich die B1-Prüfung beim ersten Mal bestanden! Die Erklärung ist einfach und die Nachbereitung ist hervorragend.',
      'faq_title': 'Häufig gestellte Fragen',
      'faq_q1': 'Brauche ich Vorkenntnisse in Deutsch?',
      'faq_a1': 'Nein, der A1-Kurs beginnt für Sie völlig bei Null.',
      'faq_q2': 'Wie erfolgt die Zahlung?',
      'faq_a2': 'Sie können über Vodafone Cash, InstaPay oder Banküberweisung bezahlen.',
      'faq_q3': 'Ist das Zertifikat akkreditiert?',
      'faq_a3': 'Wir bereiten Sie auf das Bestehen der international akkreditierten Prüfungen vor.',
      
      // Admin Drawer
      'admin_dashboard': 'Admin-Dashboard',
      'student_management': 'Studentenverwaltung',
      'course_management': 'Kursverwaltung',
      'earnings_collection': 'Einnahmen & Inkasso',
      'send_alerts': 'Benachrichtigungen senden',
      'settings': 'Einstellungen',
      'system_admin': 'Systemadministrator',
      'deutsch_welt_academy': 'Deutsch Welt Akademie',
      'logout_success': 'Erfolgreich ausgeloggt',

      // Admin Student Edit
      'first_name': 'Vorname',
      'last_name': 'Nachname',
      'email': 'E-Mail',
      'phone': 'Telefonnummer',
      'field_required': 'Dieses Feld ist erforderlich',
      'invalid_email': 'Ungültige E-Mail-Adresse',
      'active_student': 'Aktiver Student',
      'save_changes': 'Änderungen speichern',
      'add_student': 'Student hinzufügen',
      'edit_student': 'Studentendaten bearbeiten',
      'student_added': 'Student erfolgreich hinzugefügt ✅',
      'student_updated': 'Studentendaten aktualisiert ✅',
      'confirm_delete': 'Löschen bestätigen',
      'delete_student_prompt': 'Möchten Sie diesen Studenten wirklich löschen?',
      'cancel': 'Abbrechen',
      'delete': 'Löschen',
      'student_deleted': 'Student erfolgreich gelöscht',
      'no_students_found': 'Keine Studenten gefunden',

      // Book Section
      'book_title': 'Das Buch von Herr Khaled Al-Halawani',
      'pdf_ebook_pages': 'E-Book PDF • [pages] Seiten',
      'current_price': 'Aktueller Preis',
      'pdf_preview': 'PDF-Vorschau',
      'about_book': 'Über das Buch',
      'why_book_special': 'Warum ist dieses Buch besonders?',
      'order_book_whatsapp': 'Buch jetzt per WhatsApp bestellen',
      'currently_unavailable': 'Derzeit nicht verfügbar',
      'book_preview_title': 'Buchvorschau',
      'book_preview_coming_soon': 'Die Buchvorschau ist bald verfügbar.\nUm Ihr Exemplar zu erhalten, klicken Sie auf "Jetzt per WhatsApp bestellen".',
      'login_required_title': 'Anmeldung erforderlich',
      'login_required_desc': 'Melden Sie sich zuerst an, um das Buch zu bestellen.',
      'student_role': 'Schüler',
      'not_specified': 'Nicht angegeben',
      'cannot_open_whatsapp': 'WhatsApp kann derzeit nicht geöffnet werden',
      'cannot_open_file': 'Datei kann nicht geöffnet werden',
      'ok': 'OK',
      'instructor_book_quote': '"Dieses Buch ist die Essenz von allem, was ich beim Deutschunterricht gelernt habe, entwickelt als dein Begleiter auf deiner gesamten Reise."',
      'order_confirmation_title': 'Bestellbestätigung',
      'order_confirmation_subtitle': 'Überweisen Sie den Betrag und wir aktivieren das Buch und stellen den PDF-Link sofort bereit 🚀',
      'transfer_instructions': 'Details zur Überweisung:',
      'vodafone_cash_number': 'Vodafone Cash / InstaPay Nummer:',
      'amount_to_transfer': 'Zu überweisender Betrag:',
      'copy_number': 'Nummer kopieren',
      'number_copied': 'Vodafone Cash Nummer erfolgreich kopiert 📋',
      'whatsapp_transfer_note': 'Klicken Sie nach der Überweisung auf die Schaltfläche unten, um zu WhatsApp zu gelangen und den Screenshot der Überweisung zur sofortigen Aktivierung Ihres Kontos zu senden.',
      'confirm_and_open_whatsapp': 'Bestätigen & per WhatsApp senden 📲',
      'payment_method_title': 'Zahlungsmethode & Bestellabschluss',
      'book_price_label': 'Buchpreis: [price] EGP',
      'select_payment_method': 'Bitte wählen Sie die passende Zahlungsmethode:',
      'vodafone_cash': 'Vodafone Cash',
      'instapay': 'InstaPay',
      'bank_transfer': 'Direkte Banküberweisung',
      'coming_soon': 'Demnächst ⏳',
      'payment_note': '💡 Nach Abschluss der Überweisung speichern Sie bitte einen Screenshot der Überweisung und klicken Sie auf die Schaltfläche unten, um ihn zu senden und die Bestellung zu bestätigen.',
      'send_transfer': 'Überweisung senden',

      // Profile Section
      'account_status': 'Kontostatus',
      'active_status': 'Aktiv ✅',
      'no_phone': 'Keine Telefonnummer',
      'user_fallback': 'Benutzer',
      'edit_profile': 'Profil bearbeiten',
      'edit_personal_info': 'Persönliche Daten bearbeiten',
      'save_edits': 'Änderungen speichern',
      'change_password': 'Passwort ändern',
      'current_password': 'Aktuelles Passwort',
      'new_password': 'Neues Passwort',
      'confirm_new_password': 'Neues Passwort bestätigen',
      'update_password': 'Passwort aktualisieren',
      'update_success': 'Ihre Daten wurden erfolgreich aktualisiert! 🎉',
      'update_failed': 'Aktualisierung fehlgeschlagen',
      'password_change_success': 'Passwort erfolgreich geändert! 🎉',
      'password_change_failed': 'Passwortänderung fehlgeschlagen',
      'passwords_dont_match': 'Die Passwörter stimmen nicht überein',
      'password_min_length': 'Passwort muss mindestens 8 Zeichen lang sein',
      'dark_mode': 'Dunkelmodus (Dark Mode)',
      'light_mode': 'Heller Modus (Light Mode)',
    }
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

extension TranslationExtension on BuildContext {
  String translate(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }
}
