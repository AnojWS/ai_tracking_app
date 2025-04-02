import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';

/// A class representing the form factor of different devices.
abstract class FormFactor {
  /// The width value representing a tablet device.
  static double tablet = 600;

  /// The width value representing a mobile device.
  static double mobile = 300;
}

enum ScreenSize { mobile, tablet }

/// Extension methods for the ScreenSize enum to provide convenience properties for checking if the size is mobile or tablet.
extension ScreenSizeExtension on ScreenSize {
  /// Returns true if the ScreenSize is mobile.
  bool get isMobile => this == ScreenSize.mobile;

  /// Returns true if the ScreenSize is tablet.
  bool get isTablet => this == ScreenSize.tablet;
}

/// Extension methods for the BuildContext class to provide convenience property for checking if the device is a mobile device.
extension BuildContextExtension on BuildContext {
  /// Returns true if the device type in the provided context is mobile.
  bool get isMobileDevice => getDeviceType(this) == ScreenSize.mobile;
}

/// Returns the ScreenSize based on the device width in the provided [BuildContext].
ScreenSize getDeviceType(BuildContext context) {
  // Retrieve the device width using MediaQuery
  double deviceWidth = MediaQuery.of(context).size.shortestSide;

  // Determine the ScreenSize based on the device width
  if (deviceWidth > FormFactor.tablet) {
    return ScreenSize.tablet;
  } else {
    return ScreenSize.mobile;
  }
}

/// Returns the design size based on the ScreenSize in the provided [BuildContext].
material.Size getDesignSize(BuildContext context) {
  final designSize = getDeviceType(context);

  // Return the design size based on the ScreenSize
  switch (designSize) {
    case ScreenSize.mobile:
      return const material.Size(390, 844);
    case ScreenSize.tablet:
      return const material.Size(768, 1024);
  }
}
