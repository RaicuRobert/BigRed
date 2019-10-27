class Product{
  String name;
  String barcode;
  String category;
  int quantity;

  Product(this.name, this.category, this.quantity, this.barcode);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        json['name'],
        json['category'],
        json['quantity'],
        json['barcode'],
    );
  }
}