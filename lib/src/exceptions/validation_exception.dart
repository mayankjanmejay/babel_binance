import 'binance_exception.dart';

/// Exception for input validation errors (client-side)
class BinanceValidationException extends BinanceException {
  final String fieldName;
  final dynamic invalidValue;
  final String constraint;

  BinanceValidationException({
    required this.fieldName,
    required this.invalidValue,
    required this.constraint,
  }) : super(message: 'Validation failed for $fieldName: $constraint');

  @override
  String toString() => 'BinanceValidationException: $fieldName = "$invalidValue" - $constraint';
}
