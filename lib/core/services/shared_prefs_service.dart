import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/cart_item.dart';

class SharedPrefsService {
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  factory SharedPrefsService() => _instance;
  SharedPrefsService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Cart methods
  Future<void> saveCart(List<CartItem> cart) async {
    await init();
    final jsonList = cart.map((c) => c.toJson()).toList();
    await _prefs!.setString('cart', jsonEncode(jsonList));
  }

  Future<List<CartItem>> loadCart() async {
    await init();
    final str = _prefs!.getString('cart');
    if (str == null) return [];
    final List<dynamic> jsonList = jsonDecode(str);
    return jsonList.map((e) => CartItem.fromJson(e)).toList();
  }

  // Add other methods as needed (user, orders, etc.)
}
