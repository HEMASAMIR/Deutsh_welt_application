import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

/// Certificate generation service for Deutsch Welt Akademie.
/// Uses the official German certificate template image (`assets/images/certificate_template.jpg`)
/// and overlays the student's name, language level, and completion date dynamically.
class CertificateService {
  CertificateService._();

  // ─── Level Display Map ───────────────────────────────────────────────────────
  static const Map<String, String> _levelLabels = {
    'a1': 'A1',
    'a2': 'A2',
    'b1': 'B1',
    'b2': 'B2',
    'c1': 'C1',
    'c2': 'C2',
  };

  /// Generates a high-quality PDF certificate with student name, level, and date overlaid on the official template image.
  static Future<Uint8List> generate({
    required String studentName,
    required String levelName,
    DateTime? completedAt,
  }) async {
    final date = completedAt ?? DateTime.now();
    final dateStr = DateFormat('MM / yyyy').format(date); // e.g. "08 / 2026"
    final fullDateStr = DateFormat('dd.MM.yyyy').format(date);

    // Resolve level key
    final levelKey = levelName.toLowerCase().replaceAll(' ', '');
    final shortLevel = _levelLabels[levelKey] ?? levelName.toUpperCase();

    // Load fonts
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBold = await PdfGoogleFonts.cairoBold();
    final latinFont = await PdfGoogleFonts.montserratMedium();
    final latinBold = await PdfGoogleFonts.montserratBold();
    final scriptFont = await PdfGoogleFonts.alexBrushRegular();

    // Load background certificate template image
    final bgImageData = await rootBundle.load('assets/images/certificate_template.jpg');
    final bgImage = pw.MemoryImage(bgImageData.buffer.asUint8List());

    final doc = pw.Document(
      title: 'Zertifikat — $shortLevel — $studentName',
      author: 'Deutsche Welt Akademie',
      creator: 'Herr Khaled ElHalawany',
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4, // A4 Portrait matching the template image
        margin: pw.EdgeInsets.zero,
        build: (ctx) {
          return pw.Stack(
            children: [
              // ── 1. Template Background Image ─────────────────────────────
              pw.Positioned.fill(
                child: pw.Image(
                  bgImage,
                  fit: pw.BoxFit.cover,
                ),
              ),

              // ── 2. Student Name (Overlaid on top of dashed line) ─────────
              pw.Positioned(
                top: 250,
                left: 40,
                right: 40,
                child: pw.Center(
                  child: pw.Text(
                    studentName.trim().isEmpty ? 'الطالب الكريم' : studentName,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: arabicBold,
                      fontSize: 24,
                      color: const PdfColor.fromInt(0xFF1E293B),
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
              ),

              // ── 3. German Dynamic Text (Level & Date filled in) ───────────
              pw.Positioned(
                top: 310,
                left: 55,
                right: 55,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Hiermit wird bestätigt, dass er den Deutschkurs auf dem',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: latinFont,
                        fontSize: 12,
                        color: const PdfColor.fromInt(0xFF0F172A),
                        lineSpacing: 3,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Sprachniveau ',
                          style: pw.TextStyle(
                            font: latinFont,
                            fontSize: 12,
                            color: const PdfColor.fromInt(0xFF0F172A),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: const PdfColor.fromInt(0xFF1E3A8A),
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text(
                            shortLevel,
                            style: pw.TextStyle(
                              font: latinBold,
                              fontSize: 13,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.Text(
                          '  im  ',
                          style: pw.TextStyle(
                            font: latinFont,
                            fontSize: 12,
                            color: const PdfColor.fromInt(0xFF0F172A),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: const PdfColor.fromInt(0xFF1E3A8A), width: 1),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            dateStr,
                            style: pw.TextStyle(
                              font: latinBold,
                              fontSize: 12,
                              color: const PdfColor.fromInt(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        pw.Text(
                          '  erfolgreich abgeschlossen hat und',
                          style: pw.TextStyle(
                            font: latinFont,
                            fontSize: 12,
                            color: const PdfColor.fromInt(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── 4. Issue Date (Bottom Left) ─────────────────────────────
              pw.Positioned(
                bottom: 35,
                left: 60,
                child: pw.Text(
                  'Datum: $fullDateStr',
                  style: pw.TextStyle(
                    font: latinFont,
                    fontSize: 9,
                    color: const PdfColor.fromInt(0xFF475569),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
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
      filename: 'Zertifikat_${levelName}_$studentName.pdf',
    );
  }

  /// Opens a print preview dialog for the certificate.
  static Future<void> previewAndPrint({
    required String studentName,
    required String levelName,
    DateTime? completedAt,
  }) async {
    await Printing.layoutPdf(
      name: 'Zertifikat_${levelName}_$studentName',
      onLayout: (_) => generate(
        studentName: studentName,
        levelName: levelName,
        completedAt: completedAt,
      ),
    );
  }
}
