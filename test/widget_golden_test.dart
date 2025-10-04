import 'dart:typed_data';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_test_sample/main.dart';
import 'package:image/image.dart' as img;

import 'support/alchemist/golden_test_device_scenario.dart';

void main() {
  group('MyApp Golden Test', () {
    Future<void> customPrecacheImages(WidgetTester tester) async {
      await tester.runAsync(() async {
        final images = <Future<void>>[];
        for (final element in find.byType(Image).evaluate()) {
          final widget = element.widget as Image;
          images.add(_precacheWithGifFrame(widget.image, element));
        }
        for (final element in find.byType(FadeInImage).evaluate()) {
          final widget = element.widget as FadeInImage;
          images.add(_precacheWithGifFrame(widget.image, element));
        }
        for (final element in find.byType(DecoratedBox).evaluate()) {
          final widget = element.widget as DecoratedBox;
          final decoration = widget.decoration;
          if (decoration is BoxDecoration && decoration.image != null) {
            images.add(_precacheWithGifFrame(decoration.image!.image, element));
          }
        }
        await Future.wait(images);
      });
      await tester.pumpAndSettle();
    }

    Widget buildMyApp() {
      return const MainApp();
    }

    final device = Device.phonePortrait;

    goldenTest(
      'Default',
      fileName: 'my_app_default',
      pumpBeforeTest: customPrecacheImages,
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

Future<void> _precacheWithGifFrame(
  ImageProvider<Object> provider,
  Element element,
) async {
  if (provider is AssetImage &&
      provider.assetName.toLowerCase().endsWith('.gif')) {
    final configuration = createLocalImageConfiguration(element);
    final key = await provider.obtainKey(configuration);
    final pngBytes = await _gifFrameToPng(key, frameIndex: 0);
    final memoryImage = MemoryImage(pngBytes, scale: key.scale);
    await precacheImage(memoryImage, element);
    return;
  }

  await precacheImage(provider, element);
}

Future<Uint8List> _gifFrameToPng(
  AssetBundleImageKey key, {
  required int frameIndex,
}) async {
  final bundle = key.bundle;
  final data = await bundle.load(key.name);
  final frame = img.decodeGif(data.buffer.asUint8List(), frame: frameIndex);
  if (frame == null) {
    throw StateError('フレームを取得できませんでした: ${key.name} (frame: $frameIndex)');
  }
  return Uint8List.fromList(img.encodePng(frame, singleFrame: true));
}
