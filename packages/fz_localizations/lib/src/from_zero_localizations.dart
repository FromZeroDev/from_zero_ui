import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FromZeroLocalizations {
  final Locale locale;

  FromZeroLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static FromZeroLocalizations of(BuildContext context) {
    return Localizations.of<FromZeroLocalizations>(context, FromZeroLocalizations)!;
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<FromZeroLocalizations> delegate = _FromZeroLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString;
    try {
      jsonString = await rootBundle.loadString('packages/from_zero_ui/assets/i18n/${locale.languageCode}.json');
    } catch (_) {
      jsonString = await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
    }

    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    return _localizedStrings[key]!;
  }
}

class _FromZeroLocalizationsDelegate extends LocalizationsDelegate<FromZeroLocalizations> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _FromZeroLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<FromZeroLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    FromZeroLocalizations localizations = FromZeroLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_FromZeroLocalizationsDelegate old) => false;
}
