import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String selectedSize;
  final String selectedColor;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize = '',
    this.selectedColor = '',
  });

  String get uniqueId =>
      '${product.id}_${selectedSize.trim()}_${selectedColor.trim()}';

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'selectedSize': selectedSize,
    'selectedColor': selectedColor,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      selectedSize: json['selectedSize'] as String? ?? '',
      selectedColor: json['selectedColor'] as String? ?? '',
    );
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }
}
