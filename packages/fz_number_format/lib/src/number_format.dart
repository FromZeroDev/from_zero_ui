import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';

// We can't extend NumberFormat because the constructors are private and only factories are public :))
class ExtendedNumberFormat implements NumberFormat {
  final NumberFormat? _formatter;

  ExtendedNumberFormat(String newPattern, [String locale = 'en']) //
    : _formatter = NumberFormat(newPattern, locale);

  ExtendedNumberFormat.empty() //
    : _formatter = null;

  ExtendedNumberFormat.fromFormatter(NumberFormat formatter) //
    : _formatter = formatter;

  @override
  String toString() => _formatter.toString();

  @override
  String format(number) {
    if (number == null) return '';
    if (number == -0) number = 0;
    final result = _formatter?.format(number) ?? '';
    if (result == 'NaN') {
      return '';
    }
    return result;
  }

  String? tryFormat(dynamic number) {
    try {
      return format(number);
    } catch (_) {}
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
    } catch (_) {}
    return null;
  }

  // necessary overrides because we are implementing with a proxy instead of extending

  @override
  R parseWith<R, P extends NumberParserBase<R>>(P Function(NumberFormat p1, String p2) parserGenerator, String text) =>
      _formatter!.parseWith<R, P>(parserGenerator, text); // TODO: 3 this will crash if _formatter==null
  @override
  R? tryParseWith<R, P extends NumberParserBase<R>>(
    P Function(NumberFormat p1, String p2) parserGenerator,
    String text,
  ) => _formatter?.tryParseWith<R, P>(parserGenerator, text);

  @override
  String? get currencyName => _formatter?.currencyName;
  @override
  set currencyName(String? currencyName) => _formatter?.currencyName = currencyName;

  @override
  int get maximumFractionDigits => _formatter?.maximumFractionDigits ?? 0;
  @override
  set maximumFractionDigits(int maximumFractionDigits) => _formatter?.maximumFractionDigits = maximumFractionDigits;

  @override
  int get maximumIntegerDigits => _formatter?.maximumIntegerDigits ?? 0;
  @override
  set maximumIntegerDigits(int maximumIntegerDigits) => _formatter?.maximumIntegerDigits = maximumIntegerDigits;

  @override
  int get minimumExponentDigits => _formatter?.minimumExponentDigits ?? 0;
  @override
  set minimumExponentDigits(int minimumExponentDigits) => _formatter?.minimumExponentDigits = minimumExponentDigits;

  @override
  int get minimumFractionDigits => _formatter?.minimumFractionDigits ?? 0;
  @override
  set minimumFractionDigits(int minimumFractionDigits) => _formatter?.minimumFractionDigits = minimumFractionDigits;

  @override
  int get minimumIntegerDigits => _formatter?.minimumIntegerDigits ?? 0;
  @override
  set minimumIntegerDigits(int minimumIntegerDigits) => _formatter?.minimumIntegerDigits = minimumIntegerDigits;

  @override
  // ignore: deprecated_member_use
  int? get significantDigits => _formatter?.significantDigits;
  @override
  set significantDigits(int? significantDigits) => _formatter?.significantDigits = significantDigits;

  @override
  bool get significantDigitsInUse => _formatter?.significantDigitsInUse ?? false;
  @override
  set significantDigitsInUse(bool minimumIntegerDigits) => _formatter?.significantDigitsInUse = significantDigitsInUse;

  @override
  String get currencySymbol => _formatter?.currencySymbol ?? '';

  @override
  int? get decimalDigits => _formatter?.decimalDigits;

  @override
  String get locale => _formatter?.locale ?? '';

  @override
  int get localeZero => _formatter?.localeZero ?? 0;

  @override
  int get multiplier => _formatter?.multiplier ?? 0;

  @override
  String get negativePrefix => _formatter?.negativePrefix ?? '';

  @override
  String get negativeSuffix => _formatter?.negativeSuffix ?? '';

  @override
  String get positivePrefix => _formatter?.positivePrefix ?? '';

  @override
  String get positiveSuffix => _formatter?.positiveSuffix ?? '';

  @override
  String simpleCurrencySymbol(String currencyCode) => _formatter?.simpleCurrencySymbol(currencyCode) ?? '';

  @override
  NumberSymbols get symbols => _formatter!.symbols; // TODO: 3 this will crash if _formatter==null

  @override
  void turnOffGrouping() => _formatter?.turnOffGrouping();

  @override
  int? get maximumSignificantDigits => _formatter?.maximumSignificantDigits;
  @override
  set maximumSignificantDigits(int? maximumSignificantDigits) =>
      _formatter?.maximumSignificantDigits = maximumSignificantDigits;

  @override
  int? get minimumSignificantDigits => _formatter?.minimumSignificantDigits;
  @override
  set minimumSignificantDigits(int? minimumSignificantDigits) =>
      _formatter?.minimumSignificantDigits = minimumSignificantDigits;

  @override
  bool get minimumSignificantDigitsStrict => _formatter?.minimumSignificantDigitsStrict ?? false;
  @override
  set minimumSignificantDigitsStrict(bool minimumSignificantDigitsStrict) =>
      _formatter?.minimumSignificantDigitsStrict = minimumSignificantDigitsStrict;
}
