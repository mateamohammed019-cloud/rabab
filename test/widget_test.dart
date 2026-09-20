import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rabab/main.dart';

void main() {
  testWidgets('App shows the name رباب', (WidgetTester tester) async {
    await tester.pumpWidget(const RababApp());

    expect(find.text('رباب'), findsOneWidget);
    expect(find.text('هدية خاصة لكِ 🎀'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);

    // التخلص من شجرة الواجهة لإيقاف مؤقّت التقليب التلقائي.
    await tester.pumpWidget(const SizedBox());
  });
}