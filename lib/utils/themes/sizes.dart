import 'package:flutter/material.dart';

class AppSizes {

  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  //Alto
  static double smallSpace(BuildContext context) => screenHeight(context) * 0.01;
  static double mediumSpace(BuildContext context) => screenHeight(context) * 0.03;
  static double largeSpace(BuildContext context) => screenHeight(context) * 0.05;

  //Ancho
  static double smallWidthSpace(BuildContext context) => screenWidth(context) * 0.01;
  static double mediumWidthSpace(BuildContext context) => screenWidth(context) * 0.03;
  static double largeWidthSpace(BuildContext context) => screenWidth(context) * 0.03;

  //Custom alto
  static double customSizeHeight(BuildContext context, double percentage) {
    return screenHeight(context) * percentage;
  }

  //Custom ancho
  static double customSizeWidth(BuildContext context, double percentage) {
    return screenWidth(context) * percentage;
  }
}
