import 'dart:ui' as ui;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_test_sample/main.dart';

import 'support/alchemist/golden_test_device_scenario.dart';

void main() {
  group('MyApp Golden Test', () {
    Future<void> customPrecacheImages(WidgetTester tester) async {
      await tester.runAsync(() async {
        final images = <Future<void>>[];
        for (final element in find.byType(Image).evaluate()) {
          final widget = element.widget as Image;
          final image = widget.image;
          images.add(precacheImage(image, element));
        }
        for (final element in find.byType(FadeInImage).evaluate()) {
          final widget = element.widget as FadeInImage;
          final image = widget.image;
          images.add(precacheImage(image, element));
        }
        for (final element in find.byType(DecoratedBox).evaluate()) {
          final widget = element.widget as DecoratedBox;
          final decoration = widget.decoration;
          if (decoration is BoxDecoration && decoration.image != null) {
            final image = decoration.image!.image;
            images.add(precacheImage(image, element));
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
