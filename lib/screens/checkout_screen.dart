import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/store_config.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/settings_provider.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _zipController;

  String _paymentMethod = 'Cash on Delivery (Demo)';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<SettingsProvider>(
      context,
      listen: false,
    ).userProfile;
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _addressController = TextEditingController(text: profile.address);
    _cityController = TextEditingController(text: profile.city);
    _zipController = TextEditingController(text: profile.postalCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Demonstration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'DEMONSTRATION CHECKOUT: No actual credit card information will be requested or charged. Orders are saved locally for demonstration purposes.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '1. Delivery Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter your name'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (val) => val == null || !val.contains('@')
                          ? 'Enter a valid email'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter phone' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter city' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _zipController,
                      decoration: const InputDecoration(
                        labelText: 'Postal / Zip Code',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter code' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '2. Shipping Speed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RadioListTile<String>(
                value: 'standard',
                groupValue: cart.shippingMethod,
                onChanged: (val) {
                  if (val != null) cart.setShippingMethod(val);
                },
                title: const Text('Standard Delivery (3-5 Business Days)'),
                subtitle: Text(
                  cart.subtotal >= StoreConfig.freeShippingThreshold
                      ? 'FREE (Orders over \$50)'
                      : '${StoreConfig.currencySymbol}${StoreConfig.standardShippingFee.toStringAsFixed(2)}',
                ),
              ),
              RadioListTile<String>(
                value: 'express',
                groupValue: cart.shippingMethod,
                onChanged: (val) {
                  if (val != null) cart.setShippingMethod(val);
                },
                title: const Text('Express Delivery (1-2 Business Days)'),
                subtitle: Text(
                  '${StoreConfig.currencySymbol}${StoreConfig.expressShippingFee.toStringAsFixed(2)}',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '3. Demo Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPaymentOption(
                'Cash on Delivery (Demo)',
                Icons.local_atm_outlined,
              ),
              _buildPaymentOption(
                'Demo Credit / Debit Card (Simulated)',
                Icons.credit_card_outlined,
              ),
              _buildPaymentOption(
                'Demo Mobile Wallet / Pay (Simulated)',
                Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? StoreConfig.cardColorDark
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Items Total (${cart.itemCount})'),
                        Text(
                          '${StoreConfig.currencySymbol}${cart.subtotal.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    if (cart.discount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Coupon (${cart.appliedCoupon?.code})',
                            style: const TextStyle(color: Colors.green),
                          ),
                          Text(
                            '-${StoreConfig.currencySymbol}${cart.discount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shipping Fee'),
                        Text(
                          cart.shippingFee == 0
                              ? 'FREE'
                              : '${StoreConfig.currencySymbol}${cart.shippingFee.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimated Tax (8%)'),
                        Text(
                          '${StoreConfig.currencySymbol}${cart.estimatedTax.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${StoreConfig.currencySymbol}${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: StoreConfig.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoreConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Complete Demo Order (${StoreConfig.currencySymbol}${cart.totalAmount.toStringAsFixed(2)})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    return RadioListTile<String>(
      value: title,
      groupValue: _paymentMethod,
      onChanged: (val) {
        if (val != null) setState(() => _paymentMethod = val);
      },
      secondary: Icon(icon, color: StoreConfig.primaryColor),
      title: Text(title, style: const TextStyle(fontSize: 14)),
    );
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final cart = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final newOrder = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      orderDate: DateTime.now(),
      items: List.from(cart.cartList),
      subtotal: cart.subtotal,
      discount: cart.discount,
      shippingFee: cart.shippingFee,
      tax: cart.estimatedTax,
      total: cart.totalAmount,
      status: OrderStatus.processing,
      customerName: _nameController.text.trim(),
      customerEmail: _emailController.text.trim(),
      shippingAddress:
          '${_addressController.text.trim()}, ${_cityController.text.trim()} ${_zipController.text.trim()}',
      paymentMethod: _paymentMethod,
      appliedCoupon: cart.appliedCoupon?.code ?? '',
    );

    await orderProvider.placeOrder(newOrder);
    cart.clearCart();

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(order: newOrder),
        ),
      );
    }
  }
}
