import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/screens/document_medical_progress.dart';

DocumentMedicalProgress progress({
  String? status = 'ready',
  bool dirty = false,
  bool renderError = false,
  int? pages,
  int reviewed = 0,
}) => DocumentMedicalProgress(
  status: status,
  dirty: dirty,
  renderError: renderError,
  pageCount: pages,
  reviewedPageCount: reviewed,
);

void main() {
  test('all pages must be examined before a new review is complete', () {
    expect(progress().reviewComplete, isFalse);
    expect(progress(pages: 2, reviewed: 1).reviewComplete, isFalse);
    final complete = progress(pages: 2, reviewed: 2);
    expect(complete.reviewComplete, isTrue);
    expect(complete.validationRecorded, isFalse);
    expect(complete.reviewSubtitle, '2 / 2 page(s) examinée(s)');
  });

  for (final state in ['approved', 'test_approved']) {
    test(
      '$state keeps the review complete after temporary pages are cleared',
      () {
        final before = progress(pages: 2, reviewed: 2);
        expect(before.reviewComplete, isTrue);
        final saved = progress(status: state, reviewed: 2);
        expect(saved.reviewComplete, isTrue);
        expect(saved.validationRecorded, isTrue);
        expect(saved.reviewSubtitle, 'Revue enregistrée avec la validation');
      },
    );

    test(
      '$state restores the review completion when the screen is reopened',
      () {
        final reopened = progress(status: state);
        expect(reopened.reviewComplete, isTrue);
        expect(reopened.validationRecorded, isTrue);
        expect(reopened.reviewSubtitle, 'Revue enregistrée avec la validation');
      },
    );

    test('$state does not mark an unsaved context as complete', () {
      final changed = progress(
        status: state,
        dirty: true,
        pages: 2,
        reviewed: 2,
      );
      expect(changed.reviewComplete, isFalse);
      expect(changed.validationRecorded, isFalse);
    });
  }

  test('an invalidated approval requires a new review', () {
    final invalidated = progress(status: 'invalidated', reviewed: 2);
    expect(invalidated.reviewComplete, isFalse);
    expect(invalidated.validationRecorded, isFalse);
    expect(invalidated.reviewSubtitle, 'Revue à commencer');
    final reread = progress(status: 'invalidated', pages: 2, reviewed: 2);
    expect(reread.reviewComplete, isTrue);
    expect(reread.validationRecorded, isFalse);
  });

  test('missing or blocked status never implies a recorded approval', () {
    for (final state in [null, 'ready', 'blocked', 'unknown']) {
      expect(progress(status: state).reviewComplete, isFalse);
      expect(progress(status: state).validationRecorded, isFalse);
    }
  });

  test('an unreadable preview cannot complete a new review', () {
    final unreadable = progress(renderError: true, pages: 1, reviewed: 1);
    expect(unreadable.reviewComplete, isFalse);
    expect(unreadable.validationRecorded, isFalse);
  });

  test(
    'an absent or empty review is never treated as a completed new review',
    () {
      expect(progress().reviewComplete, isFalse);
      expect(progress(pages: 0).reviewComplete, isFalse);
      expect(progress(pages: 2, reviewed: 3).reviewComplete, isFalse);
    },
  );
}
