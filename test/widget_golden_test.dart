import 'dart:ui' as ui;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_test_sample/main.dart';

import 'support/alchemist/golden_test_device_scenario.dart';

void main() {
  group('MyApp Golden Test', () {
    Future<void> precacheGoldenImages(WidgetTester tester) async {
      await tester.runAsync(() async {
        final assetImages = <AssetBundleImageProvider>{};

        void collect(ImageProvider provider) {
          if (provider is AssetBundleImageProvider) {
            assetImages.add(provider);
          }
        }

        for (final element in find.byType(Image).evaluate()) {
          final widget = element.widget as Image;
          collect(widget.image);
        }

        for (final element in find.byType(FadeInImage).evaluate()) {
          final widget = element.widget as FadeInImage;
          collect(widget.image);
        }

        for (final element in find.byType(DecoratedBox).evaluate()) {
          final decoration = (element.widget as DecoratedBox).decoration;
          if (decoration is BoxDecoration) {
            final image = decoration.image?.image;
            if (image is AssetBundleImageProvider) {
              assetImages.add(image);
            }
          }
        }

        for (final provider in assetImages) {
          final key = await provider.obtainKey(const ImageConfiguration());
          final data = await key.bundle.load(key.name);
          final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
          final frame = await codec.getNextFrame();
          frame.image.dispose();
          codec.dispose();
        }
      });

      // GIF など継続再生する画像でも描画を一度だけ進めれば十分
      await tester.pump(const Duration(milliseconds: 100));
    }

    Widget buildMyApp() {
      return const MainApp();
    }

    final device = Device.phonePortrait;

    goldenTest(
      'Default',
      fileName: 'my_app_default',
      pumpBeforeTest: precacheGoldenImages,
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
