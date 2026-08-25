import 'package:flutter_test/flutter_test.dart';
import 'package:quotebiz/main.dart';

void main() {
  testWidgets('QuoteBiz smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuoteBizApp());
    expect(find.text('QuoteBiz'), findsWidgets);
  });
}
