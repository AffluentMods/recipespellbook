import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'app_enums.dart';

/// Provides localized unit names and measurement system handling
class LocalizedUnits {
  final AppLocalizations l10n;

  LocalizedUnits(this.l10n);

  static LocalizedUnits of(BuildContext context) {
    return LocalizedUnits(AppLocalizations.of(context)!);
  }

  // ============ VOLUME UNITS ============

  String get unitCup => l10n.unitCup;
  String get unitCups => l10n.unitCups;
  String get unitTablespoon => l10n.unitTablespoon;
  String get unitTablespoonAbbrev => l10n.unitTablespoonAbbrev;
  String get unitTeaspoon => l10n.unitTeaspoon;
  String get unitTeaspoonAbbrev => l10n.unitTeaspoonAbbrev;
  String get unitFluidOunce => l10n.unitFluidOunce;
  String get unitFluidOunceAbbrev => l10n.unitFluidOunceAbbrev;
  String get unitPint => l10n.unitPint;
  String get unitQuart => l10n.unitQuart;
  String get unitGallon => l10n.unitGallon;
  String get unitMilliliter => l10n.unitMilliliter;
  String get unitMilliliterAbbrev => l10n.unitMilliliterAbbrev;
  String get unitLiter => l10n.unitLiter;
  String get unitLiterAbbrev => l10n.unitLiterAbbrev;

  // ============ WEIGHT UNITS ============

  String get unitOunce => l10n.unitOunce;
  String get unitOunceAbbrev => l10n.unitOunceAbbrev;
  String get unitPound => l10n.unitPound;
  String get unitPoundAbbrev => l10n.unitPoundAbbrev;
  String get unitGram => l10n.unitGram;
  String get unitGramAbbrev => l10n.unitGramAbbrev;
  String get unitKilogram => l10n.unitKilogram;
  String get unitKilogramAbbrev => l10n.unitKilogramAbbrev;

  // ============ OTHER UNITS ============

  String get unitPinch => l10n.unitPinch;
  String get unitDash => l10n.unitDash;
  String get unitClove => l10n.unitClove;
  String get unitCloves => l10n.unitCloves;
  String get unitHead => l10n.unitHead;
  String get unitBunch => l10n.unitBunch;
  String get unitCan => l10n.unitCan;
  String get unitPackage => l10n.unitPackage;
  String get unitSlice => l10n.unitSlice;
  String get unitSlices => l10n.unitSlices;
  String get unitPiece => l10n.unitPiece;
  String get unitPieces => l10n.unitPieces;
  String get unitWhole => l10n.unitWhole;
  String get unitLarge => l10n.unitLarge;
  String get unitMedium => l10n.unitMedium;
  String get unitSmall => l10n.unitSmall;

  // ============ TEMPERATURE ============

  String get unitFahrenheit => l10n.unitFahrenheit;
  String get unitCelsius => l10n.unitCelsius;

  /// Format a unit for display based on amount (singular/plural)
  String formatUnit(String unitKey, double amount) {
    final isPlural = amount != 1.0;

    switch (unitKey.toLowerCase()) {
      case 'cup':
        return isPlural ? unitCups : unitCup;
      case 'tbsp':
        return unitTablespoonAbbrev;
      case 'tsp':
        return unitTeaspoonAbbrev;
      case 'oz':
        return unitOunceAbbrev;
      case 'lb':
        return unitPoundAbbrev;
      case 'g':
        return unitGramAbbrev;
      case 'kg':
        return unitKilogramAbbrev;
      case 'ml':
        return unitMilliliterAbbrev;
      case 'l':
        return unitLiterAbbrev;
      case 'clove':
        return isPlural ? unitCloves : unitClove;
      case 'slice':
        return isPlural ? unitSlices : unitSlice;
      case 'piece':
        return isPlural ? unitPieces : unitPiece;
      default:
        return unitKey;
    }
  }

  /// Get all common units for a dropdown picker
  List<UnitOption> getVolumeUnits(MeasurementSystem system) {
    if (system == MeasurementSystem.metric) {
      return [
        UnitOption(key: 'ml', display: unitMilliliterAbbrev),
        UnitOption(key: 'l', display: unitLiterAbbrev),
      ];
    } else {
      return [
        UnitOption(key: 'tsp', display: unitTeaspoonAbbrev),
        UnitOption(key: 'tbsp', display: unitTablespoonAbbrev),
        UnitOption(key: 'cup', display: unitCup),
        UnitOption(key: 'fl oz', display: unitFluidOunceAbbrev),
        UnitOption(key: 'pint', display: unitPint),
        UnitOption(key: 'quart', display: unitQuart),
        UnitOption(key: 'gallon', display: unitGallon),
      ];
    }
  }

  List<UnitOption> getWeightUnits(MeasurementSystem system) {
    if (system == MeasurementSystem.metric) {
      return [
        UnitOption(key: 'g', display: unitGramAbbrev),
        UnitOption(key: 'kg', display: unitKilogramAbbrev),
      ];
    } else {
      return [
        UnitOption(key: 'oz', display: unitOunceAbbrev),
        UnitOption(key: 'lb', display: unitPoundAbbrev),
      ];
    }
  }

  List<UnitOption> getCountUnits() {
    return [
      UnitOption(key: 'whole', display: unitWhole),
      UnitOption(key: 'piece', display: unitPiece),
      UnitOption(key: 'slice', display: unitSlice),
      UnitOption(key: 'clove', display: unitClove),
      UnitOption(key: 'head', display: unitHead),
      UnitOption(key: 'bunch', display: unitBunch),
      UnitOption(key: 'can', display: unitCan),
      UnitOption(key: 'package', display: unitPackage),
      UnitOption(key: 'pinch', display: unitPinch),
      UnitOption(key: 'dash', display: unitDash),
      UnitOption(key: 'large', display: unitLarge),
      UnitOption(key: 'medium', display: unitMedium),
      UnitOption(key: 'small', display: unitSmall),
    ];
  }
}

class UnitOption {
  final String key;     // Internal key (stored in DB)
  final String display; // Localized display name

  const UnitOption({required this.key, required this.display});
}

/// Determines the default measurement system based on locale
MeasurementSystem getDefaultMeasurementSystem(Locale locale) {
  // Countries that use US customary units
  const usCustomaryCountries = ['US', 'LR', 'MM']; // USA, Liberia, Myanmar

  if (usCustomaryCountries.contains(locale.countryCode)) {
    return MeasurementSystem.us;
  }

  return MeasurementSystem.metric;
}

/// Determines the default temperature unit based on locale
TemperatureUnit getDefaultTemperatureUnit(Locale locale) {
  // Countries that use Fahrenheit
  const fahrenheitCountries = ['US', 'BS', 'KY', 'LR', 'PW', 'FM', 'MH'];

  if (fahrenheitCountries.contains(locale.countryCode)) {
    return TemperatureUnit.fahrenheit;
  }

  return TemperatureUnit.celsius;
}

enum TemperatureUnit { fahrenheit, celsius }