import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';


class ExtendedNumberFormat extends MyNumberFormat{

  static final emptyNumberFormatter = ExtendedNumberFormat(null);
  static final doubleDecimalNumberFormatter = ExtendedNumberFormat("###,###,###,###,##0.00");
  static final tripleDecimalNumberFormatter = ExtendedNumberFormat("###,###,###,###,##0.000");
  static final quadDecimalNumberFormatter = ExtendedNumberFormat("###,###,###,###,##0.0000");
  static final percentageDecimalNumberFormatter = ExtendedNumberFormat("###,###,###,###,##0.00%");
  static final percentageNoDecimalNumberFormatter = ExtendedNumberFormat("###,###,###,###,##0%");
  static final percentageSingleDecimalNumberFormatter = ExtendedNumberFormat("###,###,###,###,##0.0%");
  static final loosePercentageDecimalNumberFormatter = ExtendedNumberFormat("###,###,###,###,##0.#%");
  static final loosePercentageDecimalNumberFormatterSmall = ExtendedNumberFormat("###,###,###,###,##0.#");
  static final loosePercentageDecimalNumberFormatterSmallest = ExtendedNumberFormat("###,###,###,###,##0");
  static final noDecimalNumberFormatter = ExtendedNumberFormat("###,###,###,###,##0");

  late NumberFormat? _formatter;

  ExtendedNumberFormat(String? newPattern, [String locale='en']) {
    _formatter = newPattern==null ? null : NumberFormat(newPattern, locale);
  }

  @override
  String toString() => _formatter.toString();

  @override
  String format(number) {
    if (number==null) return '';
    if (number==-0) number = 0;
    final result = _formatter?.format(number) ?? '';
    if (result=='NaN') {
      return '';
    }
    return result;
  }

  String? tryFormat(dynamic number) {
    try {
      return format(number);
    } catch(_) {}
    return null;
  }

  @override
  num parse(number) {
    return _formatter?.parse(number) ?? num.parse(number);
  }
  @override
  num? tryParse(dynamic number) {
    try {
      return parse(number);
    } catch(_) {}
    return null;
  }

  @override
  R parseWith<R, P extends NumberParserBase<R>>(P Function(NumberFormat p1, String p2) parserGenerator, String text) => _formatter!.parseWith<R, P>(parserGenerator, text);
  @override
  R? tryParseWith<R, P extends NumberParserBase<R>>(P Function(NumberFormat p1, String p2) parserGenerator, String text)  => _formatter!.tryParseWith<R, P>(parserGenerator, text);

}


class EmptyNumberFormat extends MyNumberFormat{

  late NumberFormat _formatter;

  EmptyNumberFormat() {
    _formatter = NumberFormat('');
  }

  @override
  String format(number) {
    return '';
  }

  @override
  num parse(number) {
    return _formatter.parse(number);
  }
  @override
  num? tryParse(dynamic number) {
    try {
      return parse(number);
    } catch(_) {}
    return null;
  }

  @override
  R parseWith<R, P extends NumberParserBase<R>>(P Function(NumberFormat p1, String p2) parserGenerator, String text) => _formatter.parseWith<R, P>(parserGenerator, text);
  @override
  R? tryParseWith<R, P extends NumberParserBase<R>>(P Function(NumberFormat p1, String p2) parserGenerator, String text)  => _formatter.tryParseWith<R, P>(parserGenerator, text);

}


abstract class MyNumberFormat implements NumberFormat{

  @override
  String? currencyName;

  @override
  int maximumFractionDigits = 0;

  @override
  int maximumIntegerDigits = 0;

  @override
  int minimumExponentDigits = 0;

  @override
  int minimumFractionDigits = 0;

  @override
  int minimumIntegerDigits = 0;

  @override
  int? significantDigits;

  @override
  bool significantDigitsInUse = false;

  @override
  String get currencySymbol => throw UnimplementedError();

  @override
  int? get decimalDigits => throw UnimplementedError();

  @override
  String get locale => throw UnimplementedError();

  @override
  int get localeZero => throw UnimplementedError();

  @override
  int get multiplier => throw UnimplementedError();

  @override
  String get negativePrefix => throw UnimplementedError();

  @override
  String get negativeSuffix => throw UnimplementedError();

  @override
  String get positivePrefix => throw UnimplementedError();

  @override
  String get positiveSuffix => throw UnimplementedError();

  @override
  String simpleCurrencySymbol(String currencyCode) {
    throw UnimplementedError();
  }

  @override
  NumberSymbols get symbols => throw UnimplementedError();

  @override
  void turnOffGrouping() {}

  @override
  int? maximumSignificantDigits;

  @override
  int? minimumSignificantDigits;

  @override
  bool minimumSignificantDigitsStrict = false;

}