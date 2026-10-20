import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/exam_model.dart';

class PdfService {
  static Future<pw.Document> generateExamPdf(ExamModel exam) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoBold();
    final fontRegular = await PdfGoogleFonts.cairoRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return [
            // 1. الكليشة العلوية المطابقة تماماً للصورة
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              children: [
                pw.TableRow(
                  children: [
                    // اليمين: الترويسة الرسمية
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Column(
                        children: [
                          pw.Text(exam.header.country, style: pw.TextStyle(font: font, fontSize: 9)),
                          pw.Text(exam.header.ministry, style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                          pw.Text(exam.header.directorate, style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                          pw.Text(exam.header.school, style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                        ],
                      ),
                    ),
                    // الوسط: الشعار و بسملة
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('بسم الله الرحمن الرحيم', style: pw.TextStyle(font: font, fontSize: 10)),
                          pw.SizedBox(height: 5),
                          // يمكن إضافة شعار شعار الدولة هنا كـ Image
                          pw.Text('🦅', style: const pw.TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                    // اليسار: معلومات المادة والاختبار
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Table(
                        border: pw.TableBorder.all(width: 0.5),
                        children: [
                          _buildRow('المادة:', exam.header.subject, font, fontRegular),
                          _buildRow('الاختبار:', exam.header.examType, font, fontRegular),
                          _buildRow('الصف:', exam.header.grade, font, fontRegular),
                          _buildRow('الزمن:', exam.header.duration, font, fontRegular),
                          _buildRow('الفترة:', exam.header.period, font, fontRegular),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 2. جدول اسم الطالب والدرجة
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      alignment: pw.Alignment.center,
                      child: pw.Text('اسم الطالب', style: pw.TextStyle(font: font, fontSize: 10)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      alignment: pw.Alignment.center,
                      child: pw.Text('درجة الطالب', style: pw.TextStyle(font: font, fontSize: 10)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      alignment: pw.Alignment.center,
                      child: pw.Text(exam.header.totalGrade, style: pw.TextStyle(font: font, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 15),

            // 3. عرض الأسئلة بحسب النوع
            ...exam.questions.map((q) => _buildQuestionWidget(q, font, fontRegular)).toList(),

            // 4. الخاتمة
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text('انتهت الأسئلة', style: pw.TextStyle(font: font, fontSize: 12)),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  static pw.TableRow _buildRow(String label, String value, pw.Font fontB, pw.Font fontR) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 2),
          child: pw.Text(label, style: pw.TextStyle(font: fontB, fontSize: 8)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 2),
          child: pw.Text(value, style: pw.TextStyle(font: fontR, fontSize: 8)),
        ),
      ],
    );
  }

  static pw.Widget _buildQuestionWidget(Question q, pw.Font fontB, pw.Font fontR) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // عنوان السؤال مع مربع الدرجة
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(q.title, style: pw.TextStyle(font: fontB, fontSize: 10)),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                child: pw.Text('${q.score} درجات', style: pw.TextStyle(font: fontR, fontSize: 8)),
              ),
            ],
          ),
          pw.SizedBox(height: 6),

          // تفاصيل السؤال حسب النوع (مثل صح/خطأ أو التوصيل)
          if (q.typeIndex == 0) ...[ // صح وخطأ
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('#', style: pw.TextStyle(font: fontB))),
                    pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('العبارة', style: pw.TextStyle(font: fontB))),
                    pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('الإجابة', style: pw.TextStyle(font: fontB))),
                  ],
                ),
                ...q.items.asMap().entries.map((e) => pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${e.key + 1}')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(e.value, style: pw.TextStyle(font: fontR))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('(   )')),
                  ],
                )),
              ],
            )
          ] else ...[
            // بقية أنواع الأسئلة (مقالي، صور، إلخ)
            ...q.items.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(item, style: pw.TextStyle(font: fontR, fontSize: 10)),
            )),
          ],
        ],
      ),
    );
  }
}
