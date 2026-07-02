import 'package:flutter_test/flutter_test.dart';
import 'package:control_electoral_2026/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ControlElectoralApp());
    expect(find.text('Control Electoral'), findsOneWidget);
  });
}
