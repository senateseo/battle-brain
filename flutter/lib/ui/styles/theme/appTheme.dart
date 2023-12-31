import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTheme { light, dark }

final appThemeData = {
  AppTheme.light: ThemeData(
    brightness: Brightness.light,
    canvasColor: onBackgroundColor,
    fontFamily: GoogleFonts.montserrat().fontFamily,
    primaryColor: primaryColor,
    primaryTextTheme: GoogleFonts.montserratTextTheme(),
    cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
      textTheme: CupertinoTextThemeData(
        textStyle: GoogleFonts.montserrat(),
      ),
    ),
    scaffoldBackgroundColor: pageBackgroundColor,
    shadowColor: primaryColor.withOpacity(0.25),
    textTheme: GoogleFonts.montserratTextTheme(),
    tabBarTheme: TabBarTheme(
      labelColor: backgroundColor,
      labelStyle: GoogleFonts.montserrat(
        textStyle: const TextStyle(
          fontWeight: FontWeights.regular,
          fontSize: 14,
        ),
      ),
      unselectedLabelColor: Colors.black26,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: primaryColor,
      ),
    ),
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    colorScheme: ThemeData()
        .colorScheme
        .copyWith(
          secondary: secondaryColor,
          onPrimary: onPrimaryColor,
          background: backgroundColor,
          onSecondary: onSecondaryColor,
          onTertiary: primaryTxtColor,
          onSurface: levelLockedColor,
        )
        .copyWith(background: backgroundColor),
  ),
  AppTheme.dark: ThemeData(
    primaryTextTheme: GoogleFonts.montserratTextTheme(),
    textTheme: GoogleFonts.montserratTextTheme(),
    fontFamily: GoogleFonts.montserrat().fontFamily,
    shadowColor: darkPrimaryColor.withOpacity(0.25),
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkPageBackgroundColor,
    canvasColor: darkCanvasColor,
    tabBarTheme: TabBarTheme(
      labelColor: darkCanvasColor,
      labelStyle: GoogleFonts.montserrat(
        textStyle: const TextStyle(
          fontWeight: FontWeights.regular,
          fontSize: 14,
        ),
      ),
      unselectedLabelColor: Colors.black26,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: primaryColor,
      ),
    ),
    cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
      textTheme: CupertinoTextThemeData(
        textStyle: GoogleFonts.montserrat(),
      ),
    ),
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    colorScheme: ThemeData()
        .colorScheme
        .copyWith(
          brightness: Brightness.dark,
          secondary: darkSecondaryColor,
          onPrimary: darkOnPrimaryColor,
          background: darkBackgroundColor,
          onSecondary: darkOnSecondaryColor,
          onTertiary: darkPrimaryTxtColor,
          onSurface: darkLevelLockedColor,
        )
        .copyWith(background: darkBackgroundColor),
  ),
};
