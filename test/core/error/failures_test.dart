import 'package:cash_distro/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failures', () {
    test('ServerFailure supports value equality', () {
      expect(
        const ServerFailure('timeout'),
        equals(const ServerFailure('timeout')),
      );
    });

    test('CacheFailure supports value equality', () {
      expect(
        const CacheFailure('read error'),
        equals(const CacheFailure('read error')),
      );
    });

    test('NetworkFailure supports value equality', () {
      expect(
        const NetworkFailure(),
        equals(const NetworkFailure()),
      );
    });
  });
}
