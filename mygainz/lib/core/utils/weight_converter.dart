/// Utility class for handling weight conversions between kg and lbs
/// This eliminates the repeated conversion logic throughout the codebase
class WeightConverter {
  static const double _kgToLbsRatio = 2.20462;
  static const double _lbsToKgRatio = 0.453592;

  /// Converts weight from kg to lbs
  static double kgToLbs(double weightInKg) {
    return weightInKg * _kgToLbsRatio;
  }

  /// Converts weight from lbs to kg
  static double lbsToKg(double weightInLbs) {
    return weightInLbs * _lbsToKgRatio;
  }

  /// Converts weight from storage unit (kg) to display unit based on user preference
  /// @param weightInKg: Weight stored in kg (base unit)
  /// @param displayUnit: User's preferred display unit ('kg' or 'lbs')
  /// @return: Weight in display unit
  static double toDisplayUnit(double weightInKg, String displayUnit) {
    switch (displayUnit.toLowerCase()) {
      case 'lbs':
        return kgToLbs(weightInKg);
      case 'kg':
      default:
        return weightInKg;
    }
  }

  /// Converts weight from display unit to storage unit (kg)
  /// @param displayWeight: Weight in user's preferred unit
  /// @param displayUnit: User's preferred display unit ('kg' or 'lbs')
  /// @return: Weight in kg (storage unit)
  static double toStorageUnit(double displayWeight, String displayUnit) {
    switch (displayUnit.toLowerCase()) {
      case 'lbs':
        return lbsToKg(displayWeight);
      case 'kg':
      default:
        return displayWeight;
    }
  }

  /// Formats weight with appropriate precision and unit
  /// @param weightInKg: Weight stored in kg
  /// @param displayUnit: User's preferred display unit
  /// @param precision: Number of decimal places (default: 1)
  /// @return: Formatted string with weight and unit
  static String formatWeight(double weightInKg, String displayUnit,
      {int precision = 1}) {
    final displayWeight = toDisplayUnit(weightInKg, displayUnit);
    return '${displayWeight.toStringAsFixed(precision)}$displayUnit';
  }

  /// Parses weight string to double and converts to storage unit
  /// @param weightString: String representation of weight
  /// @param displayUnit: Current display unit of the weight string
  /// @return: Weight in kg (storage unit) or null if parsing fails
  static double? parseToStorageUnit(String weightString, String displayUnit) {
    final displayWeight = double.tryParse(weightString);
    if (displayWeight == null) return null;
    return toStorageUnit(displayWeight, displayUnit);
  }

  /// Validates that a weight value is reasonable
  /// @param weightInKg: Weight in kg to validate
  /// @return: true if weight is reasonable (0.1kg to 1000kg)
  static bool isValidWeight(double weightInKg) {
    return weightInKg >= 0.1 && weightInKg <= 1000.0;
  }

  /// Gets the appropriate unit symbol for display
  static String getUnitSymbol(String unit) {
    switch (unit.toLowerCase()) {
      case 'lbs':
        return 'lbs';
      case 'kg':
      default:
        return 'kg';
    }
  }
}
