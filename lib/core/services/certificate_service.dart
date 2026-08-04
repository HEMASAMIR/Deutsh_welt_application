import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

/// Certificate generation service for Deutsch Welt Akademie.
/// Generates a high-quality A4 landscape PDF certificate with the student's
/// name, level, date, and the instructor's signature placeholder.
class CertificateService {
  CertificateService._();

  // ─── Brand Colors ────────────────────────────────────────────────────────────
  static const _navy = PdfColor.fromInt(0xFF1E3A8A);
  static const _navyDark = PdfColor.fromInt(0xFF172554);
  static const _gold = PdfColor.fromInt(0xFFD4AF37);
  static const _goldLight = PdfColor.fromInt(0xFFF5E6A3);
  static const _white = PdfColors.white;
  static const _lightGray = PdfColor.fromInt(0xFFF8FAFC);
  static const _textDark = PdfColor.fromInt(0xFF1F2937);
  static const _textMid = PdfColor.fromInt(0xFF6B7280);

  // ─── Level Display Map ───────────────────────────────────────────────────────
  static const Map<String, String> _levelLabels = {
    'a1': 'A1 — Einsteiger | مبتدئ',
    'a2': 'A2 — Grundlagen | أساسيات',
    'b1': 'B1 — Mittelstufe | متوسط',
    'b2': 'B2 — Fortgeschrittene | متقدم',
    'c1': 'C1 — Kompetent | ماهر',
    'c2': 'C2 — Meister | محترف',
  };

  /// Generates a certificate PDF as bytes.
  ///
  /// [studentName] — Full name of the student.
  /// [levelName]   — Level identifier (e.g., "A1", "B2").
  /// [completedAt] — Completion date (defaults to today).
  static Future<Uint8List> generate({
    required String studentName,
    required String levelName,
    DateTime? completedAt,
  }) async {
    final date = completedAt ?? DateTime.now();
    final dateStr = DateFormat('dd / MM / yyyy').format(date);

    // Load fonts
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBold = await PdfGoogleFonts.cairoBold();
    final latinFont = await PdfGoogleFonts.playfairDisplayRegular();
    final latinBold = await PdfGoogleFonts.playfairDisplayBold();
    final latinItalic = await PdfGoogleFonts.playfairDisplayItalic();

    // Resolve level label
    final levelKey = levelName.toLowerCase().replaceAll(' ', '');
    final levelLabel = _levelLabels[levelKey] ??
        _levelLabels.entries
            .firstWhere(
              (e) => levelKey.contains(e.key),
              orElse: () => MapEntry('', levelName),
            )
            .value;

    final doc = pw.Document(
      title: 'شهادة إتمام — $levelName — $studentName',
      author: 'Deutsch Welt Akademie',
      creator: 'Herr Khaled Al-Helwani',
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => _buildCertificate(
          ctx: ctx,
          studentName: studentName,
          levelLabel: levelLabel,
          dateStr: dateStr,
          arabicFont: arabicFont,
          arabicBold: arabicBold,
          latinFont: latinFont,
          latinBold: latinBold,
          latinItalic: latinItalic,
        ),
      ),
    );

    return doc.save();
  }

  // ─── Certificate Layout ──────────────────────────────────────────────────────
  static pw.Widget _buildCertificate({
    required pw.Context ctx,
    required String studentName,
    required String levelLabel,
    required String dateStr,
    required pw.Font arabicFont,
    required pw.Font arabicBold,
    required pw.Font latinFont,
    required pw.Font latinBold,
    required pw.Font latinItalic,
  }) {
    return pw.Stack(
      children: [
        // ── Background ──────────────────────────────────────────────────────
        pw.Positioned.fill(
          child: pw.Container(
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
                colors: [_lightGray, _white],
              ),
            ),
          ),
        ),

        // ── Navy side bar — left ────────────────────────────────────────────
        pw.Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 16,
          child: pw.Container(color: _navyDark),
        ),
        // ── Navy side bar — right ───────────────────────────────────────────
        pw.Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 16,
          child: pw.Container(color: _navyDark),
        ),
        // ── Gold stripe — left ──────────────────────────────────────────────
        pw.Positioned(
          left: 16,
          top: 0,
          bottom: 0,
          width: 6,
          child: pw.Container(color: _gold),
        ),
        // ── Gold stripe — right ─────────────────────────────────────────────
        pw.Positioned(
          right: 16,
          top: 0,
          bottom: 0,
          width: 6,
          child: pw.Container(color: _gold),
        ),

        // ── Top navy header band ────────────────────────────────────────────
        pw.Positioned(
          top: 0,
          left: 22,
          right: 22,
          height: 60,
          child: pw.Container(
            color: _navy,
            child: pw.Center(
              child: pw.Text(
                'DEUTSCH WELT AKADEMIE  ·  دويتش فيلت أكاديمي',
                style: pw.TextStyle(
                  font: latinFont,
                  fontSize: 11,
                  color: _goldLight,
                  letterSpacing: 2.5,
                ),
              ),
            ),
          ),
        ),

        // ── Bottom navy footer band ─────────────────────────────────────────
        pw.Positioned(
          bottom: 0,
          left: 22,
          right: 22,
          height: 44,
          child: pw.Container(
            color: _navyDark,
            child: pw.Center(
              child: pw.Text(
                'www.deutschwelt.com  ·  هذه الشهادة تُثبت إتمام المستوى بنجاح',
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 9,
                  color: _goldLight,
                ),
              ),
            ),
          ),
        ),

        // ── Decorative corner ornaments ─────────────────────────────────────
        pw.Positioned(
          top: 68,
          left: 36,
          child: _ornament(),
        ),
        pw.Positioned(
          top: 68,
          right: 36,
          child: _ornament(),
        ),
        pw.Positioned(
          bottom: 52,
          left: 36,
          child: _ornament(),
        ),
        pw.Positioned(
          bottom: 52,
          right: 36,
          child: _ornament(),
        ),

        // ── Main content ────────────────────────────────────────────────────
        pw.Positioned(
          top: 60,
          left: 22,
          right: 22,
          bottom: 44,
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ── "Certificate of Completion" ─────────────────────────────
                pw.Text(
                  'Certificate of Completion',
                  style: pw.TextStyle(
                    font: latinItalic,
                    fontSize: 15,
                    color: _gold,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 4),

                // ── Arabic subtitle ─────────────────────────────────────────
                pw.Text(
                  'شهادة إتمام',
                  style: pw.TextStyle(
                    font: arabicBold,
                    fontSize: 22,
                    color: _navy,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 10),

                // ── Thin gold divider ───────────────────────────────────────
                pw.Container(
                  width: 200,
                  height: 1.5,
                  color: _gold,
                ),
                pw.SizedBox(height: 18),

                // ── "This certifies that" ───────────────────────────────────
                pw.Text(
                  'تُشهد أكاديمية دويتش فيلت بأن الطالب / الطالبة',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
                    color: _textMid,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 10),

                // ── Student Name ────────────────────────────────────────────
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 32, vertical: 10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: _navy, width: 1.5),
                      top: pw.BorderSide(color: _gold, width: 1),
                    ),
                  ),
                  child: pw.Text(
                    studentName,
                    style: pw.TextStyle(
                      font: arabicBold,
                      fontSize: 26,
                      color: _textDark,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
                pw.SizedBox(height: 18),

                // ── "has successfully completed" ────────────────────────────
                pw.Text(
                  'قد أتمّ بنجاح دراسة المستوى',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
                    color: _textMid,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 8),

                // ── Level Badge ─────────────────────────────────────────────
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: _navy,
                    borderRadius: pw.BorderRadius.circular(30),
                  ),
                  child: pw.Text(
                    levelLabel,
                    style: pw.TextStyle(
                      font: arabicBold,
                      fontSize: 14,
                      color: _goldLight,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
                pw.SizedBox(height: 24),

                // ── Thin divider ────────────────────────────────────────────
                pw.Container(
                  width: 360,
                  height: 0.8,
                  color: const PdfColor.fromInt(0xFFE5E7EB),
                ),
                pw.SizedBox(height: 20),

                // ── Signature + Date row ────────────────────────────────────
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    // Date
                    pw.Column(
                      children: [
                        pw.Text(
                          dateStr,
                          style: pw.TextStyle(
                            font: latinFont,
                            fontSize: 13,
                            color: _textDark,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(width: 140, height: 1, color: _textMid),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'تاريخ الإصدار',
                          style: pw.TextStyle(
                            font: arabicFont,
                            fontSize: 10,
                            color: _textMid,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ],
                    ),

                    // Center seal
                    pw.Container(
                      width: 60,
                      height: 60,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: _gold, width: 2),
                        color: _navy,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'DW',
                          style: pw.TextStyle(
                            font: latinBold,
                            fontSize: 18,
                            color: _goldLight,
                          ),
                        ),
                      ),
                    ),

                    // Signature
                    pw.Column(
                      children: [
                        pw.Text(
                          'خالد الحلواني',
                          style: pw.TextStyle(
                            font: arabicBold,
                            fontSize: 14,
                            color: _textDark,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(width: 140, height: 1, color: _textMid),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'المؤسس والمدرب',
                          style: pw.TextStyle(
                            font: arabicFont,
                            fontSize: 10,
                            color: _textMid,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Corner Ornament ─────────────────────────────────────────────────────────
  static pw.Widget _ornament() {
    return pw.Container(
      width: 28,
      height: 28,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _gold, width: 1.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Center(
        child: pw.Container(
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(
            color: _gold,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// Saves and shares the certificate PDF using the system share sheet.
  static Future<void> shareOrSave({
    required String studentName,
    required String levelName,
    DateTime? completedAt,
  }) async {
    final bytes = await generate(
      studentName: studentName,
      levelName: levelName,
      completedAt: completedAt,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'شهادة_${levelName}_$studentName.pdf',
    );
  }

  /// Opens a print preview dialog for the certificate.
  static Future<void> previewAndPrint({
    required String studentName,
    required String levelName,
    DateTime? completedAt,
  }) async {
    await Printing.layoutPdf(
      name: 'شهادة_${levelName}_$studentName',
      onLayout: (_) => generate(
        studentName: studentName,
        levelName: levelName,
        completedAt: completedAt,
      ),
    );
  }
}
