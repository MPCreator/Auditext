import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: LightColors.primaryColor,
  scaffoldBackgroundColor: LightColors.backgroundColor,
  colorScheme: const ColorScheme.light(
    primary: LightColors.primaryColor,
    secondary: LightColors.secondaryColor,
    surface: LightColors.lightColor,
    error: LightColors.alertColor,
    onPrimary: LightColors.lightColor,
    onSecondary: LightColors.lightColor,
    onSurface: LightColors.darkColor,
    secondaryContainer: LightColors.emphasisColor,
  ).copyWith(secondary: LightColors.secondaryColor
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: LightColors.textColor),
    bodyMedium: TextStyle(color: LightColors.textColor),
    bodySmall: TextStyle(color: LightColors.textColor),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: LightColors.backgroundColor,
    iconTheme: IconThemeData(color: LightColors.darkColor, size: 40),
    titleTextStyle: TextStyle(color: LightColors.textColor, fontSize: 30, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: LightColors.lightColor, backgroundColor: LightColors.secondaryColor,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: LightColors.primaryColor, side: const BorderSide(color: LightColors.primaryColor),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: LightColors.emphasisColor,
    ),
  ),
  cardTheme: CardTheme(
    color: LightColors.lightColor,
    shadowColor: LightColors.primaryColor.withOpacity(0.3),
    elevation: 4,
  ),
);



ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: DarkColors.primaryColor,
  scaffoldBackgroundColor: DarkColors.backgroundColor,
  colorScheme: const ColorScheme.dark(
    primary: DarkColors.primaryColor,
    secondary: DarkColors.secondaryColor,
    surface: DarkColors.lightColor,
    error: DarkColors.alertColor,
    onPrimary: DarkColors.darkColor,
    onSecondary: DarkColors.darkColor,
    onSurface: DarkColors.lightColor,
    secondaryContainer: DarkColors.emphasisColor,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: DarkColors.textColor),
    bodyMedium: TextStyle(color: DarkColors.textColor),
    bodySmall: TextStyle(color: DarkColors.textColor),

  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: DarkColors.backgroundColor,
    iconTheme: IconThemeData(color: DarkColors.darkColor, size: 40),
    titleTextStyle: TextStyle(color: DarkColors.textColor, fontSize: 30, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: DarkColors.darkColor, backgroundColor: DarkColors.secondaryColor,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DarkColors.primaryColor, side: const BorderSide(color: DarkColors.primaryColor),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: DarkColors.emphasisColor,
    ),
  ),
  cardTheme: CardTheme(
    color: DarkColors.lightColor,
    shadowColor: DarkColors.primaryColor.withOpacity(0.3),
    elevation: 4,
  ),
);
