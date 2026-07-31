// lib/core/fiscal/seniat_sundde_engine.dart

enum IvaRate {
  general(0.16),
  reduced(0.08),
  additional(0.31),
  exempt(0.0);

  final double rate;
  const IvaRate(this.rate);
}

class SeniatInvoiceCalculation {
  final double subtotal;
  final IvaRate ivaRate;
  final double ivaAmount;
  final bool igtfApplies;
  final double igtfRate;
  final double igtfAmount;
  final double grandTotal;

  SeniatInvoiceCalculation({
    required this.subtotal,
    required this.ivaRate,
    required this.ivaAmount,
    required this.igtfApplies,
    required this.igtfRate,
    required this.igtfAmount,
    required this.grandTotal,
  });
}

class SunddeValidation {
  final bool isCompliant;
  final double actualMargin;
  final double maxAllowedPrice;
  final double excessAmount;

  SunddeValidation({
    required this.isCompliant,
    required this.actualMargin,
    required this.maxAllowedPrice,
    required this.excessAmount,
  });
}

class FiscalSummary {
  final SeniatInvoiceCalculation seniatCalculation;
  final SunddeValidation sunddeValidation;
  final double retentionAmount;

  FiscalSummary({
    required this.seniatCalculation,
    required this.sunddeValidation,
    required this.retentionAmount,
  });
}

class SeniatSunddeEngine {
  static const double maxProfitMarginSundde = 0.30; // 30% max

  static SeniatInvoiceCalculation calculateInvoiceTax(double subtotal, IvaRate rate, bool isForeignCurrencyCash) {
    double ivaAmount = subtotal * rate.rate;
    bool igtfApplies = isForeignCurrencyCash;
    double igtfRate = 0.03;
    double igtfAmount = igtfApplies ? subtotal * igtfRate : 0.0;
    double grandTotal = subtotal + ivaAmount + igtfAmount;

    return SeniatInvoiceCalculation(
      subtotal: subtotal,
      ivaRate: rate,
      ivaAmount: ivaAmount,
      igtfApplies: igtfApplies,
      igtfRate: igtfRate,
      igtfAmount: igtfAmount,
      grandTotal: grandTotal,
    );
  }

  static SunddeValidation validateSunddeMargin(double costUsd, double salePriceUsd) {
    double actualMargin = (salePriceUsd - costUsd) / costUsd;
    double maxAllowedPrice = calculateMaxAllowedPrice(costUsd);
    bool isCompliant = actualMargin <= maxProfitMarginSundde;
    double excessAmount = isCompliant ? 0.0 : salePriceUsd - maxAllowedPrice;

    return SunddeValidation(
      isCompliant: isCompliant,
      actualMargin: actualMargin,
      maxAllowedPrice: maxAllowedPrice,
      excessAmount: excessAmount,
    );
  }

  static double calculateMaxAllowedPrice(double costUsd) {
    return costUsd * (1 + maxProfitMarginSundde);
  }

  static double calculateFiscalRetention(double invoiceTotal, {bool isSpecialContributor = false}) {
    double retentionRate = isSpecialContributor ? 1.0 : 0.75;
    // Assuming calculation based on total for simplicity, standard requires calculation on IVA part.
    return invoiceTotal * retentionRate; 
  }

  static FiscalSummary generateCompleteFiscalSummary(
    double subtotal, 
    double cost, 
    double salePrice, 
    IvaRate ivaRate, 
    bool isForeignCash, 
    bool isSpecialContributor
  ) {
    return FiscalSummary(
      seniatCalculation: calculateInvoiceTax(subtotal, ivaRate, isForeignCash),
      sunddeValidation: validateSunddeMargin(cost, salePrice),
      retentionAmount: calculateFiscalRetention(subtotal * ivaRate.rate, isSpecialContributor: isSpecialContributor),
    );
  }
}
