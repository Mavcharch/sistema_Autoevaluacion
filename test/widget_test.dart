import 'package:flutter_test/flutter_test.dart';

import 'package:codejudge/main.dart';

void main() {
  testWidgets('App boots and shows home title', (WidgetTester tester) async {
    await tester.pumpWidget(const CodeJudgeApp());
    await tester.pump();
    expect(find.text('CodeJudge'), findsWidgets);
  });
}
