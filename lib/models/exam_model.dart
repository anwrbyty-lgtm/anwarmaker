import 'package:hive/hive.dart';

part 'exam_model.g.dart';

@HiveType(typeId: 0)
class ExamHeader extends HiveObject {
  @HiveField(0) String country;
  @HiveField(1) String ministry;
  @HiveField(2) String directorate;
  @HiveField(3) String school;
  @HiveField(4) String subject;
  @HiveField(5) String examType;
  @HiveField(6) String grade;
  @HiveField(7) String duration;
  @HiveField(8) String period;
  @HiveField(9) String totalGrade;

  ExamHeader({
    this.country = 'الجمهورية اليمنية',
    this.ministry = 'وزارة التربية والتعليم',
    this.directorate = 'مكتب التربية والتعليم م / حضرموت',
    this.school = 'مجمع 30 نوفمبر',
    this.subject = 'فيزياء',
    this.examType = 'اختبار شهري',
    this.grade = 'الثالث الثانوي',
    this.duration = '30 دقيقة',
    this.period = 'الأولى',
    this.totalGrade = '18',
  });
}

enum QuestionType { trueFalse, multipleChoice, matching, fillBlanks, essay, imageQuestion }

@HiveType(typeId: 1)
class Question extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title; // نص السؤال (مثل: السؤال الأول: ضع علامة صح أو خطأ)
  @HiveField(2) int typeIndex;
  @HiveField(3) List<String> items; // العبارات أو الخيارات
  @HiveField(4) List<String>? extraItems; // للعمود ب في التوصيل
  @HiveField(5) String score;
  @HiveField(6) String? imagePath;

  Question({
    required this.id,
    required this.title,
    required this.typeIndex,
    required this.items,
    this.extraItems,
    required this.score,
    this.imagePath,
  });
}

@HiveType(typeId: 2)
class ExamModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) DateTime createdAt;
  @HiveField(3) ExamHeader header;
  @HiveField(4) List<Question> questions;

  ExamModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.header,
    required this.questions,
  });
}
