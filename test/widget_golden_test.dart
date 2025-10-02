import 'dart:ui' as ui;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_test_sample/main.dart';

import 'support/alchemist/golden_test_device_scenario.dart';

void main() {
  group('MyApp Golden Test', () {
    Future<void> precacheAssetsSkippingAnimations(WidgetTester tester) async {
      final assetImages = <AssetImage>{};

      for (final element in find.byType(Image).evaluate()) {
        final imageProvider = (element.widget as Image).image;
        if (imageProvider is AssetImage) {
          assetImages.add(imageProvider);
        }
      }

      for (final element in find.byType(DecoratedBox).evaluate()) {
        final widget = element.widget as DecoratedBox;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration) {
          final image = decoration.image?.image;
          if (image is AssetImage) {
            assetImages.add(image);
          }
        }
      }

      await tester.runAsync(() async {
        for (final assetImage in assetImages) {
          final key = await assetImage.obtainKey(const ImageConfiguration());
          final bundle = key.bundle;
          final data = await bundle.load(key.name);
          final codec = await ui.instantiateImageCodec(
            data.buffer.asUint8List(),
          );
          final frame = await codec.getNextFrame();
          frame.image.dispose();
          codec.dispose();
        }
      });

      // GIF が次フレームを要求し続けるため pumpAndSettle は避け、描画を 1 フレーム分だけ進める
      await tester.pump(const Duration(milliseconds: 100));
    }

    Widget buildMyApp() {
      return const MainApp();
    }

    final device = Device.phonePortrait;

    goldenTest(
      'Default',
      fileName: 'my_app_default',
      pumpBeforeTest: precacheAssetsSkippingAnimations,
      builder: () {
        final children = <Widget>[];

        children.add(
          GoldenTestDeviceScenario(
            name: device.name,
            device: device,
            builder: () => buildMyApp(),
          ),
        );

        return GoldenTestGroup(columns: 1, children: children);
      },
    );
  });
}
