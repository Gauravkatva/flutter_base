// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:my_appp/app/app.dart';
import 'package:my_appp/ui/counter/counter.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(App());
      expect(find.byType(CounterPage), findsOneWidget);
    });

    testWidgets('Finds Pokemon Button', (tester) async {
      await tester.pumpWidget(App());
      expect(find.text('View Pokemon List'), findsOneWidget);
    });
  });
}
