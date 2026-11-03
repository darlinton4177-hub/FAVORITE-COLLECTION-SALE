import 'cart_item.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Order {
  final String id;
  final DateTime orderDate;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final String customerName;
  final String customerEmail;
  final String shippingAddress;
  final String paymentMethod;
  final String appliedCoupon;

  const Order({
    required this.id,
    required this.orderDate,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.tax,
    required this.total,
    this.status = OrderStatus.processing,
    required this.customerName,
    required this.customerEmail,
    required this.shippingAddress,
    required this.paymentMethod,
    this.appliedCoupon = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderDate': orderDate.toIso8601String(),
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'discount': discount,
    'shippingFee': shippingFee,
    'tax': tax,
    'total': total,
    'status': status.index,
    'customerName': customerName,
    'customerEmail': customerEmail,
    'shippingAddress': shippingAddress,
    'paymentMethod': paymentMethod,
    'appliedCoupon': appliedCoupon,
  };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      shippingFee: (json['shippingFee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.values[json['status'] as int? ?? 1],
      customerName: json['customerName'] as String? ?? 'Customer',
      customerEmail: json['customerEmail'] as String? ?? 'customer@example.com',
      shippingAddress: json['shippingAddress'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash On Delivery',
      appliedCoupon: json['appliedCoupon'] as String? ?? '',
    );
  }

  Order copyWith({
    String? id,
    DateTime? orderDate,
    List<CartItem>? items,
    double? subtotal,
    double? discount,
    double? shippingFee,
    double? tax,
    double? total,
    OrderStatus? status,
    String? customerName,
    String? customerEmail,
    String? shippingAddress,
    String? paymentMethod,
    String? appliedCoupon,
  }) {
    return Order(
      id: id ?? this.id,
      orderDate: orderDate ?? this.orderDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
    );
  }
}
