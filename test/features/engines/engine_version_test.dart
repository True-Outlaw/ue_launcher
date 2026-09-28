import 'package:flutter_test/flutter_test.dart';
import 'package:ue_launcher/features/engines/domain/entities/engine.dart';

void main() {
  group('Engine.compareVersions', () {
    test('correctly identifies newer patch versions', () {
      expect(Engine.compareVersions('5.4.4', '5.4.3'), 1);
      expect(Engine.compareVersions('5.4.3', '5.4.4'), -1);
    });

    test('correctly identifies newer minor versions', () {
      expect(Engine.compareVersions('5.5.0', '5.4.4'), 1);
      expect(Engine.compareVersions('5.4.0', '5.5.0'), -1);
    });

    test('correctly identifies newer major versions', () {
      expect(Engine.compareVersions('5.0.0', '4.27.2'), 1);
      expect(Engine.compareVersions('4.27.2', '5.0.0'), -1);
    });

    test('handles equal versions', () {
      expect(Engine.compareVersions('5.4.2', '5.4.2'), 0);
      expect(Engine.compareVersions('5.4', '5.4.0'), 0);
    });

    test('handles versions with different number of parts', () {
      expect(Engine.compareVersions('5.4.1', '5.4'), 1);
      expect(Engine.compareVersions('5.4', '5.4.1'), -1);
    });

    test('handles double-digit minor or patch versions', () {
      expect(Engine.compareVersions('5.10.0', '5.9.0'), 1);
      expect(Engine.compareVersions('5.3.12', '5.3.9'), 1);
      expect(Engine.compareVersions('5.9.0', '5.10.0'), -1);
    });
  });
}
