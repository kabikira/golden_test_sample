import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_test_sample/main.dart';

import 'support/alchemist/golden_test_device_scenario.dart';
import 'support/test_gif_to_png_asset_bundle.dart';

void main() {
  group('MyApp Golden Test', () {
    Widget buildMyApp() {
      return const MainApp();
    }

    final device = Device.phonePortrait;

    goldenTest(
      'Default',
      fileName: 'my_app_default',
      pumpBeforeTest: precacheImages,
      builder: () {
        final children = <Widget>[];

        children.add(
          GoldenTestDeviceScenario(
            name: device.name,
            device: device,
            builder: () => buildMyApp(),
          ),
        );

        return DefaultAssetBundle(
          bundle: TestGifToPngAssetBundle(rootBundle),
          child: GoldenTestGroup(children: children),
        );
      },
    );
  });
}
