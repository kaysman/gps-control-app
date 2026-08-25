import 'package:flutter_test/flutter_test.dart';
import 'package:gps_control/features/settings/cubit/brand_cubit.dart';
import 'package:gps_control/l10n/l10n.dart';

void main() {
  group('BrandCubit', () {
    test('starts on Bariox, the only implemented brand', () {
      final cubit = BrandCubit();
      expect(cubit.state, TrackerBrand.bariox);
      expect(cubit.state.isImplemented, isTrue);
      expect(TrackerBrand.teltonika.isImplemented, isFalse);
    });

    test('setBrand switches and ignores the current brand', () {
      final cubit = BrandCubit();
      final seen = <TrackerBrand>[];
      final sub = cubit.stream.listen(seen.add);

      cubit
        ..setBrand(TrackerBrand.teltonika)
        ..setBrand(TrackerBrand.teltonika);

      expect(cubit.state, TrackerBrand.teltonika);
      return Future<void>.delayed(Duration.zero, () {
        expect(seen, [TrackerBrand.teltonika]);
        return sub.cancel();
      });
    });
  });

  group('LocaleCubit', () {
    test('defaults to English', () {
      expect(LocaleCubit().state.languageCode, 'en');
      expect(LocaleCubit.supported.first.languageCode, 'en');
    });
  });
}
