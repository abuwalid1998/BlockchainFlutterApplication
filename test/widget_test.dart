import 'package:blockchain_flutter_application/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders blockchain visual builder and action button', (
    tester,
  ) async {
    await tester.pumpWidget(const BlockchainApp());

    expect(find.text('Blockchain Visual Builder'), findsOneWidget);
    expect(find.text('Create Bank Transaction'), findsOneWidget);
  });
}
