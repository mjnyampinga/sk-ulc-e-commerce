import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/cart_provider.dart' as cart_service;
import 'package:e_commerce/core/services/auth_provider.dart';
import 'package:e_commerce/core/services/firebase_service.dart';
import 'package:e_commerce/core/utils/constants.dart';
import 'package:e_commerce/data/models/order.dart' as app_order;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:e_commerce/core/services/order_provider.dart' as order_provider;

enum PaymentMethod { cash, momo }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController locationController = TextEditingController();
  final MapController mapController = MapController();
  bool _isProcessingOrder = false;

  // Sample delivery person data
  final Map<String, String> deliveryPerson = {
    'name': 'M Joselyne',
    'phone': '+250 787 438 701',
    'address': 'Gisozi ,Kg 43 st',
    'vehicle': 'Motor-cycle',
  };

  // Kigali coordinates
  final LatLng kigaliLocation = LatLng(-1.9441, 30.0619);

  // Delivery fee threshold
  double calculateDeliveryFee(double subtotal) {
    return 0;
  }

  PaymentMethod _selectedPayment = PaymentMethod.cash;
  bool showPaymentOptions = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cart = Provider.of<cart_service.CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final subtotal = cart.totalAmount;
    final deliveryFee = calculateDeliveryFee(subtotal);
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Map section with location input
                      Container(
                        height: screenHeight * 0.35,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(24)),
                        ),
                        child: Stack(
                          children: [
                            // Flutter Map
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(0)),
                              child: FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  initialCenter: kigaliLocation,
                                  initialZoom: 13,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'e.commerce',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: kigaliLocation,
                                        width: 80,
                                        height: 80,
                                        child: const Icon(
                                          Icons.location_on,
                                          color: AppConstants.primaryColor,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Location search bar
                            Positioned(
                              top: 16,
                              left: 16,
                              right: 16,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Image.asset(
                                          'assets/icons/back-5.png',
                                          width: 20,
                                          height: 33),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: locationController,
                                              decoration: const InputDecoration(
                                                hintText: 'Enter your location',
                                                border: InputBorder.none,
                                                hintStyle: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppConstants.primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Pick',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.location_on,
                                            color: Colors.white, size: 20),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Delivery person details
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppConstants.primaryColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset('assets/icons/motor.png',
                                    width: 30, height: 30),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deliveryPerson['vehicle']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  deliveryPerson['phone']!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return SizedBox(
                                  width: constraints.maxWidth,
                                  height: 1,
                                  child: CustomPaint(
                                    painter: DashedLinePainter(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  deliveryPerson['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.phone,
                                    color: AppConstants.primaryColor, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  deliveryPerson['phone']!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: AppConstants.primaryColor, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  deliveryPerson['address']!,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // After the delivery person details container
                      if (showPaymentOptions)
                        Container(
                          margin: const EdgeInsets.only(
                              top: 0, left: 16, right: 16, bottom: 0),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Radio<PaymentMethod>(
                                    value: PaymentMethod.momo,
                                    groupValue: _selectedPayment,
                                    activeColor: AppConstants.primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPayment = value!;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'MOMO',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 92),
                              Row(
                                children: [
                                  Radio<PaymentMethod>(
                                    value: PaymentMethod.cash,
                                    groupValue: _selectedPayment,
                                    activeColor: AppConstants.primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPayment = value!;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'Cash',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      // Add extra padding at the bottom for the payment section
                      const SizedBox(height: 250),
                    ],
                  ),
                ),
              ],
            ),
            // Payment section - Fixed at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total price',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'RWF ${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery fees',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Free',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: constraints.maxWidth,
                          height: 1,
                          child: CustomPaint(
                            painter: DashedLinePainter(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total cost',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'RWF ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isProcessingOrder
                            ? null
                            : () {
                                if (!showPaymentOptions) {
                                  setState(() {
                                    showPaymentOptions = true;
                                  });
                                  return;
                                }

                                if (_selectedPayment == PaymentMethod.cash) {
                                  _processOrder();
                                } else {
                                  _showMomoModal();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isProcessingOrder
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getButtonText(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward,
                                      color: Colors.white),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonText() {
    if (!showPaymentOptions) {
      return 'Pay Now';
    }
    switch (_selectedPayment) {
      case PaymentMethod.cash:
        return 'Place Order';
      case PaymentMethod.momo:
        return 'Pay with MoMo';
      default:
        return 'Pay Now';
    }
  }

  void _showMomoModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.payment, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Payment option',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Radio<PaymentMethod>(
                              value: PaymentMethod.momo,
                              groupValue: PaymentMethod.momo,
                              activeColor: Colors.blue,
                              onChanged: (_) {},
                            ),
                            Icon(Icons.account_balance_wallet,
                                color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'MoMO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: const TextField(
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '+250 787 438 701',
                              hintStyle: TextStyle(color: Colors.blueGrey),
                            ),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _processOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _processOrder() async {
    setState(() {
      _isProcessingOrder = true;
    });

    try {
      final cart =
          Provider.of<cart_service.CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.firebaseUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to place an order'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate cart
      if (cart.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your cart is empty'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Location validation has been removed.

      print('Processing order for user: ${authProvider.firebaseUser!.uid}');
      print('Cart items: ${cart.items.length}');
      print('Total amount: ${cart.totalAmount}');
      print(
          'Payment method: ${_selectedPayment == PaymentMethod.momo ? 'MoMO' : 'Cash'}');

      // Create order object
      final supplierIds = cart.items
          .map((item) => item.product.userId)
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();
      final order = app_order.Order(
        id: '', // Will be set by Firebase
        userId: authProvider.firebaseUser!.uid,
        items: cart.items,
        totalAmount: cart.totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
        shippingAddress: locationController.text.trim(),
        paymentMethod: _selectedPayment == PaymentMethod.momo ? 'MoMO' : 'Cash',
        supplierIds: supplierIds,
      );

      print('Order created, saving to Firebase...');

      // Save order to Firebase
      await Provider.of<cart_service.CartProvider>(context, listen: false)
          .clearCart();
      await Provider.of<order_provider.OrderProvider>(context, listen: false)
          .placeOrder(order);
      // Show success modal based on payment method
      _showSuccessModal(_selectedPayment);
    } catch (e) {
      print('Error processing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessingOrder = false;
      });
    }
  }

  void _showSuccessModal(PaymentMethod paymentMethod) {
    final bool isCashPayment = paymentMethod == PaymentMethod.cash;

    final String title = isCashPayment
        ? 'Order Placed, Pay in Cash'
        : 'Your Payment Is Successful';

    final Widget icon = isCashPayment
        ? const Icon(
            Icons.check_circle_outline,
            color: AppConstants.primaryColor,
            size: 100,
          )
        : Image.asset('assets/icons/celebrate.png', width: 120, height: 120);

    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Pop the dialog first, then navigate
                      Navigator.of(context).pop();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Back To Shopping',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var max = size.width;
    var dashWidth = 5;
    var dashSpace = 3;
    double startX = 0;

    while (startX < max) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
