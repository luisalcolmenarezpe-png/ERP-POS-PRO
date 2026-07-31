// lib/core/accounting/fx_currency_engine.dart

enum IsoCurrency { VES, USD, EUR, COP }

class FxTransactionRecord {
  final String id;
  final double amountBaseCurrency; // Generalmente VES
  final double amountForeignCurrency;
  final IsoCurrency foreignCurrency;
  final double exchangeRateAtTransaction; // Tasa BCV del momento
  final DateTime timestamp;

  FxTransactionRecord({
    required this.id,
    required this.amountBaseCurrency,
    required this.amountForeignCurrency,
    required this.foreignCurrency,
    required this.exchangeRateAtTransaction,
    required this.timestamp,
  });
}

class FxCurrencyEngine {
  /// Convierte monto de divisa extranjera a moneda base al tipo de cambio BCV
  static double convertToFieldCurrency({
    required double foreignAmount,
    required double bcvRate,
  }) {
    return foreignAmount * bcvRate;
  }

  /// Calula la Pérdida o Ganancia por Diferencial Cambiario (FX Gain/Loss)
  static double calculateFxGainOrLoss({
    required double foreignAmount,
    required double originalExchangeRate,
    required double settlementExchangeRate,
  }) {
    final originalBaseVal = foreignAmount * originalExchangeRate;
    final settlementBaseVal = foreignAmount * settlementExchangeRate;
    
    // Positivo = Ganancia por diferencial, Negativo = Pérdida
    return settlementBaseVal - originalBaseVal;
  }
}
