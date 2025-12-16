class ProductModel {
  final int id;
  final String name;
  final double price;
  final double? mainPrice;
  final int stock;
  final String coverImage;
  final String? weight;
  final String? description;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.mainPrice,
    required this.stock,
    required this.coverImage,
    this.weight,
    this.description,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'] ?? 'Produk tanpa nama',
      price: (map['price'] as num).toDouble(),
      mainPrice: map['main_price'] == null
          ? null
          : (map['main_price'] as num).toDouble(),
      stock: map['stock'] ?? 0,
      coverImage: map['cover_image'] ?? '',
      weight: map['weight'],
      description: map['description'],
    );
  }
}
