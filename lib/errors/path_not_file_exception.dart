class PathNotFileException implements Exception {
  String cause;
  PathNotFileException(this.cause);
}
