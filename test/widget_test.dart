import 'package:flutter_test/flutter_test.dart';
import 'package:erisim_turkiye/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Uygulamanın yüklendiğini kontrol et
    await tester.pumpWidget(const ErisilebilirTurkiyeApp());
    
    // Uygulama yüklendiğinde LoginPage veya MainNavigationPage (oturum durumuna göre) olmalı.
    // Şimdilik sadece uygulamanın patlamadan açıldığını teyit ediyoruz.
    expect(tester.takeException(), isNull);
  });
}
