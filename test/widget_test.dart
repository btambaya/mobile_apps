// Basic Flutter widget test for Thryve app

import 'package:flutter_test/flutter_test.dart';
import 'package:thryve/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ThryveApp());

    // Verify app builds without errors
    expect(find.byType(ThryveApp), findsOneWidget);
  });
}

