import 'package:chat_stats/core/widgets/ad_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdBannerFrame layout tests', () {
    testWidgets(
      'stays anchored at bottom without blocking Scaffold body',
      (tester) async {
        const screenSize = Size(400, 800);
        const adWidth = 320.0;
        const adHeight = 60.0;
        const topBorderWidth = 0.5;
        bool bodyTapped = false;

        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => bodyTapped = true,
                  child: const Text('Main Content'),
                ),
              ),
              bottomNavigationBar: const AdBannerFrame(
                width: adWidth,
                height: adHeight,
                child: SizedBox.expand(key: Key('ad-content')),
              ),
            ),
          ),
        );

        final frameFinder = find.byType(AdBannerFrame);
        final frameRect = tester.getRect(frameFinder);
        final adChildSize = tester.getSize(find.byKey(const Key('ad-content')));
        final bodyButtonFinder = find.text('Main Content');
        final bodyButtonRect = tester.getRect(bodyButtonFinder);

        expect(adChildSize, equals(const Size(adWidth, adHeight)));
        expect(frameRect.height, equals(adHeight + topBorderWidth));
        expect(frameRect.width, equals(screenSize.width));
        expect(frameRect.bottom, equals(screenSize.height));
        expect(
          frameRect.top,
          equals(screenSize.height - (adHeight + topBorderWidth)),
        );
        expect(bodyButtonRect.bottom, lessThan(frameRect.top));

        await tester.tap(bodyButtonFinder);
        expect(bodyTapped, isTrue);
      },
    );

    testWidgets(
      'accounts for bottom system padding inside SafeArea without expanding',
      (tester) async {
        const screenSize = Size(400, 800);
        const bottomInset = 24.0;
        const adWidth = 320.0;
        const adHeight = 60.0;
        const topBorderWidth = 0.5;

        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        tester.view.padding = const FakeViewPadding(bottom: bottomInset);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox.expand(),
              bottomNavigationBar: AdBannerFrame(
                width: adWidth,
                height: adHeight,
                child: ColoredBox(color: Colors.amber),
              ),
            ),
          ),
        );

        final frameRect = tester.getRect(find.byType(AdBannerFrame));
        expect(frameRect.height, equals(adHeight + bottomInset + topBorderWidth));
        expect(frameRect.bottom, equals(screenSize.height));
      },
    );
  });
}
