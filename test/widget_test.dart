// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:muzakraty/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const MuzakratyApp());
  });
}
