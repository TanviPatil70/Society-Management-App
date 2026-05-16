import 'package:flutter_test/flutter_test.dart';
import 'package:society_member_app/main.dart';

void main() {
  testWidgets('App loads role selection screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SocietyApp());

    expect(find.text('Society Member App'), findsOneWidget);
    expect(find.text('Select Your Role'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Member'), findsOneWidget);
  });
}