class ProductWithNoAPIsException implements Exception {
  String cause;
  ProductWithNoAPIsException(this.cause);
}
