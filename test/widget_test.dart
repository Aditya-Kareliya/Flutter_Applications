import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/src/features/preview_app/features/bmi_calculator/logic/bmi_provider.dart';

void main() {
  group('BmiProvider Tests', () {
    test('Initial values are correct', () {
      final provider = BmiProvider();
      expect(provider.weight, 70);
      expect(provider.height, 170);
      expect(provider.age, 25);
      expect(provider.gender, Gender.male);
    });

    test('BMI calculation is correct', () {
      final provider = BmiProvider();
      // Height 170cm = 1.7m. Weight = 70kg.
      // BMI = 70 / (1.7 * 1.7) = 70 / 2.89 ≈ 24.22
      expect(provider.bmi, closeTo(24.22, 0.01));
      expect(provider.category, 'Normal');
    });

    test('BMI updates properly', () {
      final provider = BmiProvider();
      provider.updateWeight(80);
      provider.updateHeight(180);
      // Height 180cm = 1.8m. Weight = 80kg.
      // BMI = 80 / (1.8 * 1.8) = 80 / 3.24 ≈ 24.69
      expect(provider.weight, 80);
      expect(provider.height, 180);
      expect(provider.bmi, closeTo(24.69, 0.01));
    });
  });
}

