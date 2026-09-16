import 'package:flutter_test/flutter_test.dart';
import 'package:mercadosuelto/main.dart';

void main() {
  testWidgets('Carga inicial de Mercado Suelto smoke test', (WidgetTester tester) async {
    // Construir la app y disparar un frame
    await tester.pumpWidget(const MercadoSueltoApp());

    // Verificar que el título de la AppBar se renderice
    expect(find.text('Mercado Suelto'), findsOneWidget);
  });
}