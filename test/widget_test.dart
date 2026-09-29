import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_saheli/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const WellnessSaheliApp());
    expect(find.byType(WellnessSaheliApp), findsOneWidget);
  });
}
