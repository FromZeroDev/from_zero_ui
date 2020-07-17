import 'package:flutter/material.dart';
import 'package:flutter/src/material/theme_data.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:from_zero_ui/src/settings.dart';

class ThemeParameters extends AppParametersFromZero {

  @override
  ThemeData get defaultDarkTheme => themes[3];

  @override
  ThemeData get defaultLightTheme => themes[2];

  List<Icon> get themeIcons => [Icon(MaterialCommunityIcons.theme_light_dark), Icon(Icons.check_box_outline_blank), Icon(Icons.wb_sunny), Icon(MaterialCommunityIcons.weather_night),];
  List<String> get themeNames => ["System Theme", "Clear Theme", "Light Theme", "Dark Theme"];
  List<ThemeData> get themes => [
    null,
    ThemeData( // TODO 3 make static const ThemeData definitions on settings, meant to be used with .copyWith
      canvasColor: Colors.grey.shade300,
      primaryColor: Color.fromRGBO(0, 0, 100, 1),
      primaryColorDark: Color.fromRGBO(0, 0, 60, 1),
      primaryColorLight: Color.fromRGBO(0, 0, 140, 1),
      accentColor: Colors.orangeAccent.shade700,
      visualDensity: VisualDensity.compact,
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.grey[700].withOpacity(0.9),
          borderRadius: const BorderRadius.all(Radius.circular(999999)),
        )
      ),
      primaryColorBrightness: Brightness.light,
      appBarTheme: AppBarTheme(
        color: Colors.white,
      ),
    ),
    ThemeData(
      canvasColor: Colors.grey.shade300,
      primaryColor: Color.fromRGBO(0, 0, 100, 1),
      primaryColorDark: Color.fromRGBO(0, 0, 60, 1),
      primaryColorLight: Color.fromRGBO(0, 0, 140, 1),
      accentColor: Colors.orangeAccent.shade700,
      visualDensity: VisualDensity.compact,
      tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: Colors.grey[700].withOpacity(0.9),
            borderRadius: const BorderRadius.all(Radius.circular(999999)),
          )
      ),
    ),
    ThemeData(
      brightness: Brightness.dark,
      accentColor: Colors.orangeAccent.shade700,
      visualDensity: VisualDensity.compact,
      tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.all(Radius.circular(999999)),
          )
      ),
    ),
  ];

}