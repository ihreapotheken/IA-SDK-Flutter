import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ia_example_demo/ia_example_demo.dart';
import 'package:ia_example_single_entry_point/ia_example_single_entry_point.dart';

/// The apps this example builds, one per build flavor, each from its package in `packages/`:
///
/// ```sh
/// flutter run --flavor singleEntryPoint
/// ```
///
/// Without `--flavor`, the `default-flavor` from `pubspec.yaml` is built. Each value has an Android product flavor
/// and an iOS scheme of the same name.
///
enum ExampleFlavor {
  /// The demo app, with every plugin API and the test tools.
  ///
  demo,

  /// Public example of a host app that opens the SDK from a single screen.
  ///
  singleEntryPoint;

  /// The flavor of this build. Builds without one, such as the Xcode `Runner` scheme, are the demo.
  ///
  static ExampleFlavor get current => values.firstWhere((flavor) => flavor.name == appFlavor, orElse: () => demo);

  Widget get app {
    return switch (this) {
      ExampleFlavor.demo => const DemoApp(),
      ExampleFlavor.singleEntryPoint => const SingleEntryPointApp(),
    };
  }
}
