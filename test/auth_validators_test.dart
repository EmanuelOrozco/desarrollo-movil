import 'package:flutter_test/flutter_test.dart';
import 'package:practica_clase/validators/auth_validators.dart';

void main() {
  group('AuthValidators.validateEmail', () {
    test('retorna error si el correo está vacío', () {
      expect(AuthValidators.validateEmail(''), 'El correo es obligatorio');
    });

    test('retorna null si el correo es válido', () {
      expect(AuthValidators.validateEmail('estudiante@demo.com'), isNull);
    });
  });

  group('AuthValidators.validatePassword', () {
    test('retorna error si la contraseña es corta', () {
      expect(
        AuthValidators.validatePassword('123'),
        'La contraseña debe tener mínimo 6 caracteres',
      );
    });

    test('retorna null si cumple el mínimo', () {
      expect(AuthValidators.validatePassword('123456'), isNull);
    });
  });
}
