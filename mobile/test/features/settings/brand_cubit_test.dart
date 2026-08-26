import 'package:flutter_test/flutter_test.dart';
import 'package:gps_control/features/settings/cubit/brand_cubit.dart';
import 'package:gps_control/l10n/l10n.dart';

void main() {
  group('BrandCubit', () {
    test('starts on Teltonika', () {
      expect(BrandCubit().state, TrackerBrand.teltonika);
    });

    test('only Bariox reaches the Bluetooth tab', () {
      expect(TrackerBrand.bariox.hasBleSupport, isTrue);
      expect(TrackerBrand.teltonika.hasBleSupport, isFalse);
    });

    test('setBrand switches and ignores the current brand', () {
      final cubit = BrandCubit();
      final seen = <TrackerBrand>[];
      final sub = cubit.stream.listen(seen.add);

      cubit
        ..setBrand(TrackerBrand.bariox)
        ..setBrand(TrackerBrand.bariox);

      expect(cubit.state, TrackerBrand.bariox);
      return Future<void>.delayed(Duration.zero, () {
        expect(seen, [TrackerBrand.bariox]);
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
