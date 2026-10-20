import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const ExamApp());
}

class ExamApp extends StatelessWidget {
  const ExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منشئ الاختبارات',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'YE'),
      supportedLocales: const [Locale('ar', 'YE'), Locale('ar', '')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const ExamHomeScreen(),
    );
  }
}

class ExamHomeScreen extends StatefulWidget {
  const ExamHomeScreen({super.key});

  @override
  State<ExamHomeScreen> createState() => _ExamHomeScreenState();
}

class _ExamHomeScreenState extends State<ExamHomeScreen> {
  // بيانات الترويسة
  String country = 'الجمهورية اليمنية';
  String ministry = 'وزارة التربية والتعليم';
  String directorate = 'مكتب التربية والتعليم م / حضرموت';
  String school = 'مجمع 30 نوفمبر';
  String subject = 'فيزياء';
  String examType = 'اختبار شهري';
  String grade = 'الثالث الثانوي';
  String duration = '30 دقيقة';
  String totalGrade = '18';

  List<Map<String, dynamic>> questions = [
    {
      'type': 'صح وخطأ',
      'title': 'السؤال الأول: ضع علامة صح أو خطأ أمام العبارات التالية:',
      'score': '6',
      'items': [
        'التيار الكهربائي يقاس بوحدة الأمبير.',
        'المقاومة الكلية تزداد عند التوصيل على التوازي.',
      ]
    }
  ];

  final TextEditingController _questionTextController = TextEditingController();

  void _addSymbol(String symbol) {
    _questionTextController.text = _questionTextController.text + symbol;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('منشئ الاختبارات المدرسية'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => _previewAndExportPdf(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الترويسة
              const Text('بيانات الكليشة الرسمية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: TextFormField(initialValue: subject, decoration: const InputDecoration(labelText: 'المادة'), onChanged: (v) => subject = v)),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(initialValue: examType, decoration: const InputDecoration(labelText: 'نوع الاختبار'), onChanged: (v) => examType = v)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: TextFormField(initialValue: grade, decoration: const InputDecoration(labelText: 'الصف'), onChanged: (v) => grade = v)),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(initialValue: duration, decoration: const InputDecoration(labelText: 'الزمن'), onChanged: (v) => duration = v)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // شريط رموز الرياضيات والفيزياء
              const Text('إدراج رموز رياضيات وفيزياء:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['π', '√', '²', '³', '½', '±', '≠', '≈', '≤', '≥', '∞', 'Δ', 'Ω', '∫'].map((sym) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                        onPressed: () => _addSymbol(sym),
                        child: Text(sym, style: const TextStyle(fontSize: 16)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // حقل إدخال الأسئلة
              TextField(
                controller: _questionTextController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'اكتب نص السؤال هنا...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  if (_questionTextController.text.isNotEmpty) {
                    setState(() {
                      questions.add({
                        'type': 'سؤال عام',
                        'title': _questionTextController.text,
                        'score': '3',
                        'items': []
                      });
                      _questionTextController.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة السؤال للاختبار'),
              ),
              const SizedBox(height: 15),

              // قائمة الأسئلة المضافة
              const Text('الأسئلة الحالية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...questions.asMap().entries.map((entry) {
                int idx = entry.key;
                var q = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(q['title']),
                    subtitle: Text('الدرجة: ${q['score']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          questions.removeAt(idx);
                        });
                      },
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

  void _previewAndExportPdf(BuildContext context) async {
    final pdf = pw.Document();
    final fontBold = await PdfGoogleFonts.cairoBold();
    final fontRegular = await PdfGoogleFonts.cairoRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return [
            // الكليشة
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(country, style: pw.TextStyle(font: fontBold, fontSize: 9)),
                          pw.Text(ministry, style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                          pw.Text(directorate, style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                          pw.Text(school, style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('بسم الله الرحمن الرحيم', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('المادة: $subject', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                          pw.Text('الاختبار: $examType', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                          pw.Text('الصف: $grade', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                          pw.Text('الزمن: $duration', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('اسم الطالب: .................................................', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('درجة الطالب:        / $totalGrade', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 15),

            // الأسئلة
            ...questions.map((q) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${q['title']} (${q['score']} درجات)', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                    if (q['items'] != null)
                      ...(q['items'] as List).map((item) => pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 4, right: 10),
                        child: pw.Text('- $item', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                      )),
                  ],
                ),
              );
            }),
            pw.SizedBox(height: 20),
            pw.Center(child: pw.Text('انتهت الأسئلة', style: pw.TextStyle(font: fontBold, fontSize: 11))),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
