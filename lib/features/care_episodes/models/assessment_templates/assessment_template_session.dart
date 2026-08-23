import 'assessment_template.dart';
import 'assessment_template_answers.dart';

class AssessmentTemplateSession {
  final AssessmentTemplate template;
  final AssessmentTemplateAnswers answers;

  const AssessmentTemplateSession({
    required this.template,
    required this.answers,
  });
}