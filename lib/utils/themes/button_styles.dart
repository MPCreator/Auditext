
import 'package:flutter/material.dart';

import 'colors.dart';

class ButtonStyles {
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: LightColors.lightColor, backgroundColor: LightColors.primaryColor,
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: LightColors.lightColor, backgroundColor: LightColors.secondaryColor,
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  );

  static final ButtonStyle alertButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: LightColors.lightColor, backgroundColor: LightColors.alertColor,
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  );

  static final ButtonStyle emphasisButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: LightColors.darkColor, backgroundColor: LightColors.emphasisColor,
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  );

}
