// TechBrief Widget Smoke Test

import 'package:flutter_test/flutter_test.dart';
import 'package:techbrief/main.dart';

void main() {
  testWidgets('TechBriefApp smoke test', (WidgetTester tester) async {
    // Build TechBriefApp and trigger a frame.
    await tester.pumpWidget(const TechBriefApp());
    expect(find.byType(TechBriefApp), findsOneWidget);
  });
}
