import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitsProvider with ChangeNotifier {
  // Default units
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  String _distanceUnit = 'km';

  // Loading state
  bool _isLoading = true;
  bool _isInitialized = false;

  // Getters
  String get weightUnit => _weightUnit;
  String get heightUnit => _heightUnit;
  String get distanceUnit => _distanceUnit;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // SharedPreferences key
  static const String _unitsKey = 'user_units_preferences';

  UnitsProvider() {
    _initializeUnits();
  }

  // Initialize units from SharedPreferences
  Future<void> _initializeUnits() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final unitsJson = prefs.getString(_unitsKey);

      if (unitsJson != null && unitsJson.isNotEmpty) {
        final unitsData = json.decode(unitsJson);
        _weightUnit = unitsData['weightUnit'] ?? 'kg';
        _heightUnit = unitsData['heightUnit'] ?? 'cm';
        _distanceUnit = unitsData['distanceUnit'] ?? 'km';
      }

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      print(
          'Units initialized: Weight=$_weightUnit, Height=$_heightUnit, Distance=$_distanceUnit');
    } catch (e) {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      print('Error initializing units: $e');
    }
  }

  // Save units to SharedPreferences
  Future<void> _saveUnits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unitsData = {
        'weightUnit': _weightUnit,
        'heightUnit': _heightUnit,
        'distanceUnit': _distanceUnit,
      };
      await prefs.setString(_unitsKey, json.encode(unitsData));
      print('Units saved: ${json.encode(unitsData)}');
    } catch (e) {
      print('Error saving units: $e');
    }
  }

  // Update weight unit
  Future<void> setWeightUnit(String unit) async {
    if (unit != _weightUnit) {
      _weightUnit = unit;
      await _saveUnits();
      notifyListeners();
    }
  }

  // Update height unit
  Future<void> setHeightUnit(String unit) async {
    if (unit != _heightUnit) {
      _heightUnit = unit;
      await _saveUnits();
      notifyListeners();
    }
  }

  // Update distance unit
  Future<void> setDistanceUnit(String unit) async {
    if (unit != _distanceUnit) {
      _distanceUnit = unit;
      await _saveUnits();
      notifyListeners();
    }
  }

  // Weight conversion functions
  double convertWeight(double value, {String? fromUnit, String? toUnit}) {
    fromUnit ??= 'kg'; // Default stored unit
    toUnit ??= _weightUnit; // Default display unit

    if (fromUnit == toUnit) return value;

    // Convert to kg first (base unit)
    double valueInKg = value;
    if (fromUnit == 'lbs') {
      valueInKg = value * 0.453592;
    }

    // Convert from kg to target unit
    if (toUnit == 'lbs') {
      return valueInKg / 0.453592;
    }

    return valueInKg;
  }

  // Height conversion functions
  double convertHeight(double value, {String? fromUnit, String? toUnit}) {
    fromUnit ??= 'cm'; // Default stored unit
    toUnit ??= _heightUnit; // Default display unit

    if (fromUnit == toUnit) return value;

    // Convert to cm first (base unit)
    double valueInCm = value;
    if (fromUnit == 'm') {
      valueInCm = value * 100;
    } else if (fromUnit == 'ft') {
      valueInCm = value * 30.48;
    } else if (fromUnit == 'in') {
      valueInCm = value * 2.54;
    }

    // Convert from cm to target unit
    if (toUnit == 'm') {
      return valueInCm / 100;
    } else if (toUnit == 'ft') {
      return valueInCm / 30.48;
    } else if (toUnit == 'in') {
      return valueInCm / 2.54;
    } else if (toUnit == 'ft-in') {
      return valueInCm; // Special case - we'll handle ft-in formatting separately
    }

    return valueInCm;
  }

  // Distance conversion functions
  double convertDistance(double value, {String? fromUnit, String? toUnit}) {
    fromUnit ??= 'km'; // Default stored unit
    toUnit ??= _distanceUnit; // Default display unit

    if (fromUnit == toUnit) return value;

    // Convert to km first (base unit)
    double valueInKm = value;
    if (fromUnit == 'miles') {
      valueInKm = value * 1.609344;
    }

    // Convert from km to target unit
    if (toUnit == 'miles') {
      return valueInKm / 1.609344;
    }

    return valueInKm;
  }

  // Format weight with unit
  String formatWeight(double value, {String? fromUnit, int decimals = 1}) {
    final convertedValue = convertWeight(value, fromUnit: fromUnit);
    return '${convertedValue.toStringAsFixed(decimals)} $_weightUnit';
  }

  // Format height with unit
  String formatHeight(double value, {String? fromUnit, int decimals = 0}) {
    if (_heightUnit == 'ft-in') {
      final heightInCm = convertHeight(value, fromUnit: fromUnit, toUnit: 'cm');
      final totalInches = heightInCm / 2.54;
      final feet = (totalInches / 12).floor();
      final inches = (totalInches % 12).round();
      return '$feet\'$inches"';
    } else {
      final convertedValue = convertHeight(value, fromUnit: fromUnit);
      return '${convertedValue.toStringAsFixed(decimals)} $_heightUnit';
    }
  }

  // Format distance with unit
  String formatDistance(double value, {String? fromUnit, int decimals = 2}) {
    final convertedValue = convertDistance(value, fromUnit: fromUnit);
    return '${convertedValue.toStringAsFixed(decimals)} $_distanceUnit';
  }

  // Get weight unit options
  List<String> get weightUnitOptions => ['kg', 'lbs'];

  // Get height unit options
  List<String> get heightUnitOptions => ['cm', 'ft-in'];

  // Get distance unit options
  List<String> get distanceUnitOptions => ['km', 'miles'];

  // Debug method
  String getUnitsDebug() {
    return 'UnitsProvider State:\n'
        '- Weight Unit: $_weightUnit\n'
        '- Height Unit: $_heightUnit\n'
        '- Distance Unit: $_distanceUnit\n'
        '- Initialized: $_isInitialized\n'
        '- Loading: $_isLoading';
  }
}
