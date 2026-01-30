import '../data/app_enums.dart';

/// Measurement conversion utilities for Recipe Spellbook
/// Supports both US (imperial) and Metric systems

/// Conversion factors and logic
class MeasurementConverter {
  // Volume conversions (base: ml)
  static const double _cupToMl = 236.588;
  static const double _tbspToMl = 14.787;
  static const double _tspToMl = 4.929;
  static const double _flOzToMl = 29.574;
  static const double _pintToMl = 473.176;
  static const double _quartToMl = 946.353;
  static const double _gallonToMl = 3785.41;

  // Weight conversions (base: grams)
  static const double _ozToG = 28.3495;
  static const double _lbToG = 453.592;

  // Temperature
  static double fahrenheitToCelsius(double f) => (f - 32) * 5 / 9;
  static double celsiusToFahrenheit(double c) => c * 9 / 5 + 32;

  /// Convert a measurement string from one system to another
  /// Returns null if conversion not possible
  static ConversionResult? convert({
    required double amount,
    required String unit,
    required MeasurementSystem from,
    required MeasurementSystem to,
  }) {
    if (from == to) {
      return ConversionResult(amount: amount, unit: unit);
    }

    final normalizedUnit = unit.toLowerCase().trim();

    if (from == MeasurementSystem.us && to == MeasurementSystem.metric) {
      return _usToMetric(amount, normalizedUnit);
    } else {
      return _metricToUs(amount, normalizedUnit);
    }
  }

  static ConversionResult? _usToMetric(double amount, String unit) {
    // Volume
    if (_isCup(unit)) {
      final ml = amount * _cupToMl;
      return _formatVolume(ml, MeasurementSystem.metric);
    }
    if (_isTablespoon(unit)) {
      final ml = amount * _tbspToMl;
      return ConversionResult(amount: _round(ml), unit: 'ml');
    }
    if (_isTeaspoon(unit)) {
      final ml = amount * _tspToMl;
      return ConversionResult(amount: _round(ml), unit: 'ml');
    }
    if (_isFluidOunce(unit)) {
      final ml = amount * _flOzToMl;
      return _formatVolume(ml, MeasurementSystem.metric);
    }
    if (_isPint(unit)) {
      final ml = amount * _pintToMl;
      return _formatVolume(ml, MeasurementSystem.metric);
    }
    if (_isQuart(unit)) {
      final ml = amount * _quartToMl;
      return _formatVolume(ml, MeasurementSystem.metric);
    }
    if (_isGallon(unit)) {
      final ml = amount * _gallonToMl;
      return _formatVolume(ml, MeasurementSystem.metric);
    }

    // Weight
    if (_isOunce(unit)) {
      final g = amount * _ozToG;
      return _formatWeight(g, MeasurementSystem.metric);
    }
    if (_isPound(unit)) {
      final g = amount * _lbToG;
      return _formatWeight(g, MeasurementSystem.metric);
    }

    // Temperature
    if (_isFahrenheit(unit)) {
      final c = fahrenheitToCelsius(amount);
      return ConversionResult(amount: c.round().toDouble(), unit: '°C');
    }

    return null; // Unknown unit
  }

  static ConversionResult? _metricToUs(double amount, String unit) {
    // Volume
    if (_isMilliliter(unit)) {
      return _formatVolume(amount, MeasurementSystem.us);
    }
    if (_isLiter(unit)) {
      final ml = amount * 1000;
      return _formatVolume(ml, MeasurementSystem.us);
    }

    // Weight
    if (_isGram(unit)) {
      return _formatWeight(amount, MeasurementSystem.us);
    }
    if (_isKilogram(unit)) {
      final g = amount * 1000;
      return _formatWeight(g, MeasurementSystem.us);
    }

    // Temperature
    if (_isCelsius(unit)) {
      final f = celsiusToFahrenheit(amount);
      return ConversionResult(amount: f.round().toDouble(), unit: '°F');
    }

    return null; // Unknown unit
  }

  /// Format volume to most appropriate unit
  static ConversionResult _formatVolume(double ml, MeasurementSystem system) {
    if (system == MeasurementSystem.metric) {
      if (ml >= 1000) {
        return ConversionResult(amount: _round(ml / 1000), unit: 'L');
      }
      return ConversionResult(amount: _round(ml), unit: 'ml');
    } else {
      // US system - prefer cups for larger amounts
      if (ml >= _cupToMl * 0.25) {
        final cups = ml / _cupToMl;
        if (cups >= 4) {
          return ConversionResult(amount: _round(cups / 4), unit: 'quart');
        }
        return ConversionResult(amount: _roundFraction(cups), unit: 'cup');
      }
      if (ml >= _tbspToMl * 0.5) {
        return ConversionResult(amount: _roundFraction(ml / _tbspToMl), unit: 'tbsp');
      }
      return ConversionResult(amount: _roundFraction(ml / _tspToMl), unit: 'tsp');
    }
  }

  /// Format weight to most appropriate unit
  static ConversionResult _formatWeight(double grams, MeasurementSystem system) {
    if (system == MeasurementSystem.metric) {
      if (grams >= 1000) {
        return ConversionResult(amount: _round(grams / 1000), unit: 'kg');
      }
      return ConversionResult(amount: _round(grams), unit: 'g');
    } else {
      // US system
      if (grams >= _lbToG * 0.5) {
        return ConversionResult(amount: _roundFraction(grams / _lbToG), unit: 'lb');
      }
      return ConversionResult(amount: _roundFraction(grams / _ozToG), unit: 'oz');
    }
  }

  // Unit detection helpers
  static bool _isCup(String u) => u == 'cup' || u == 'cups' || u == 'c' || u == 'c.';
  static bool _isTablespoon(String u) => u == 'tbsp' || u == 'tablespoon' || u == 'tablespoons' || u == 'tbs' || u == 't';
  static bool _isTeaspoon(String u) => u == 'tsp' || u == 'teaspoon' || u == 'teaspoons' || u == 'ts';
  static bool _isFluidOunce(String u) => u == 'fl oz' || u == 'fl. oz' || u == 'fluid ounce' || u == 'fluid ounces';
  static bool _isPint(String u) => u == 'pint' || u == 'pints' || u == 'pt';
  static bool _isQuart(String u) => u == 'quart' || u == 'quarts' || u == 'qt';
  static bool _isGallon(String u) => u == 'gallon' || u == 'gallons' || u == 'gal';
  static bool _isOunce(String u) => u == 'oz' || u == 'ounce' || u == 'ounces' && !u.contains('fl');
  static bool _isPound(String u) => u == 'lb' || u == 'lbs' || u == 'pound' || u == 'pounds';
  static bool _isFahrenheit(String u) => u == '°f' || u == 'f' || u == 'fahrenheit';

  static bool _isMilliliter(String u) => u == 'ml' || u == 'milliliter' || u == 'milliliters' || u == 'millilitre';
  static bool _isLiter(String u) => u == 'l' || u == 'liter' || u == 'liters' || u == 'litre' || u == 'litres';
  static bool _isGram(String u) => u == 'g' || u == 'gram' || u == 'grams';
  static bool _isKilogram(String u) => u == 'kg' || u == 'kilogram' || u == 'kilograms';
  static bool _isCelsius(String u) => u == '°c' || u == 'c' || u == 'celsius';

  static double _round(double value) {
    if (value >= 100) return value.round().toDouble();
    if (value >= 10) return (value * 2).round() / 2; // Round to 0.5
    return (value * 10).round() / 10; // Round to 0.1
  }

  static double _roundFraction(double value) {
    // Round to common fractions
    if ((value - value.round()).abs() < 0.1) return value.round().toDouble();
    if ((value % 1 - 0.25).abs() < 0.1) return value.floor() + 0.25;
    if ((value % 1 - 0.33).abs() < 0.1) return value.floor() + 0.33;
    if ((value % 1 - 0.5).abs() < 0.1) return value.floor() + 0.5;
    if ((value % 1 - 0.67).abs() < 0.1) return value.floor() + 0.67;
    if ((value % 1 - 0.75).abs() < 0.1) return value.floor() + 0.75;
    return (value * 4).round() / 4; // Round to quarters
  }

  /// Format a number for display (handles fractions)
  static String formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.round().toString();
    }

    final fraction = amount % 1;
    final whole = amount.floor();

    String fractionStr = '';
    if ((fraction - 0.25).abs() < 0.05) fractionStr = '¼';
    else if ((fraction - 0.33).abs() < 0.05) fractionStr = '⅓';
    else if ((fraction - 0.5).abs() < 0.05) fractionStr = '½';
    else if ((fraction - 0.67).abs() < 0.05) fractionStr = '⅔';
    else if ((fraction - 0.75).abs() < 0.05) fractionStr = '¾';
    else fractionStr = fraction.toStringAsFixed(1).substring(1); // Just decimal part

    if (whole == 0) return fractionStr;
    return '$whole $fractionStr'.trim();
  }
}

class ConversionResult {
  final double amount;
  final String unit;

  ConversionResult({required this.amount, required this.unit});

  String get formatted => '${MeasurementConverter.formatAmount(amount)} $unit';

  @override
  String toString() => formatted;
}

/// Common temperature conversions for oven temps
class OvenTemperatures {
  static const Map<int, int> fahrenheitToCelsius = {
    250: 120,
    275: 135,
    300: 150,
    325: 165,
    350: 175,
    375: 190,
    400: 200,
    425: 220,
    450: 230,
    475: 245,
    500: 260,
  };

  static String convert(String text, MeasurementSystem to) {
    // Find temperature patterns like "350°F" or "175°C"
    final fahrenheitPattern = RegExp(r'(\d+)\s*°?\s*[Ff]');
    final celsiusPattern = RegExp(r'(\d+)\s*°?\s*[Cc]');

    if (to == MeasurementSystem.metric) {
      return text.replaceAllMapped(fahrenheitPattern, (match) {
        final f = int.parse(match.group(1)!);
        final c = MeasurementConverter.fahrenheitToCelsius(f.toDouble()).round();
        return '$c°C';
      });
    } else {
      return text.replaceAllMapped(celsiusPattern, (match) {
        final c = int.parse(match.group(1)!);
        final f = MeasurementConverter.celsiusToFahrenheit(c.toDouble()).round();
        return '$f°F';
      });
    }
  }
}