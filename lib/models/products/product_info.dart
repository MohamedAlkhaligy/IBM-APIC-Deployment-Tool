class ProductInfo {
  bool isSelected;
  String filePath;
  String name;
  String title;
  String version;

  ProductInfo({
    required this.filePath,
    required this.name,
    required this.version,
    this.isSelected = false,
    String? title,
  }) : title = title ?? name;
}
