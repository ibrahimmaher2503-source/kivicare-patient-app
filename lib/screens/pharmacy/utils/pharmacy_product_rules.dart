int? pharmacyDiscountPercentage({
  required double? price,
  required double? referencePrice,
}) {
  if (price == null ||
      referencePrice == null ||
      price < 0 ||
      referencePrice <= 0 ||
      referencePrice <= price) {
    return null;
  }
  return (((referencePrice - price) / referencePrice) * 100)
      .round()
      .clamp(0, 100);
}

bool pharmacyProductIsOutOfStock(int? stockQuantity) {
  return stockQuantity != null && stockQuantity <= 0;
}
