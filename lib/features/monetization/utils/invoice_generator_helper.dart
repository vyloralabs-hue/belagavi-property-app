class InvoiceGeneratorHelper {
  InvoiceGeneratorHelper._();

  /// Calculates GST 18% tax breakdown for Indian monetization compliance
  static Map<String, double> calculateTaxBreakdown(double subtotal, double discount) {
    final taxableValue = (subtotal - discount).clamp(0.0, double.infinity);
    final cgst = taxableValue * 0.09; // 9% CGST
    final sgst = taxableValue * 0.09; // 9% SGST
    final totalGst = cgst + sgst; // 18% GST total
    final grandTotal = taxableValue + totalGst;

    return {
      'subtotal': subtotal,
      'discount': discount,
      'taxableValue': taxableValue,
      'cgst': cgst,
      'sgst': sgst,
      'totalGst': totalGst,
      'grandTotal': grandTotal,
    };
  }
}
