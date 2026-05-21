import 'package:blockchain_flutter_application/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders blockchain simulator and button', (tester) async {
    await tester.pumpWidget(const BlockchainApp());

    expect(find.text('Blockchain Node Simulator'), findsOneWidget);
    expect(find.text('Create Bank Transaction'), findsOneWidget);
  });
}
