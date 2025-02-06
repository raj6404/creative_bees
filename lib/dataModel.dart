
class Product {
  final int id;
  final String topCategory;
  final String category;
  final String subCategory;
  final String productName;
  final String? description;
  final int quantity;
  final String price;
  final String? file;
  final String? image;
  final String status;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.topCategory,
    required this.category,
    required this.subCategory,
    required this.productName,
    this.description,
    required this.quantity,
    required this.price,
    this.file,
    this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      topCategory: json['top_category'],
      category: json['category'],
      subCategory: json['sub_category'],
      productName: json['product_name'],
      description: json['description'],
      quantity: json['quantity'],
      price: json['price'],
      file: json['file'],
      image: json['image'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'top_category': topCategory,
      'category': category,
      'sub_category': subCategory,
      'product_name': productName,
      'description': description,
      'quantity': quantity,
      'price': price,
      'file': file,
      'image': image,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ApiResponse {
  final String status;
  final String message;
  final List<Product> data;

  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  // Factory constructor to create ApiResponse from JSON
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Product> productList = list.map((item) => Product.fromJson(item)).toList();

    return ApiResponse(
      status: json['status'],
      message: json['message'],
      data: productList,
    );
  }

  // Method to convert ApiResponse to JSON
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> productList = data.map((product) => product.toJson()).toList();

    return {
      'status': status,
      'message': message,
      'data': productList,
    };
  }
}