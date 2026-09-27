class VerificationEmailTemplate {
  const VerificationEmailTemplate._();

  static String html({required String recipientName, required String code}) {
    return '''
<!doctype html>
<html lang="es">
  <body style="margin:0;background:#f7f3ec;font-family:Arial,sans-serif;color:#1b1b1b;padding:32px 16px">
    <main style="max-width:560px;margin:auto;background:#ffffff;border:1px solid #e4dfd3;border-radius:12px;padding:32px">
      <p style="color:#0e3b2e;font-weight:bold;letter-spacing:1px">GEOPREDIA</p>
      <h1 style="font-size:24px">Confirma tu cuenta</h1>
      <p>Hola $recipientName, usa este código para verificar tu correo institucional:</p>
      <p style="font-size:36px;letter-spacing:8px;font-weight:bold;color:#0e3b2e;text-align:center">$code</p>
      <p style="color:#6e6e6e">El código vence en 10 minutos. Si no solicitaste esta cuenta, ignora este mensaje.</p>
    </main>
  </body>
</html>
''';
  }
}
