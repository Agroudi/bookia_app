import 'package:bookia_app/core/models/json_reader.dart';

/// One line in the cart.
///
/// The API prefixes every field with `item_`, and `item_total` is already
/// `quantity x price_after_discount`, so nothing here needs recomputing.
class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.image,
    this.priceBeforeDiscount,
    this.stock,
  });

  /// `item_id` — the handle `/update-cart` and `/remove-from-cart` expect.
  /// Note this is *not* the product id.
  final int id;

  final int productId;
  final String name;
  final int quantity;

  /// What one unit costs after discount.
  final double unitPrice;

  final double lineTotal;
  final String? image;
  final double? priceBeforeDiscount;

  /// Used to clamp the quantity stepper.
  final int? stock;

  bool get hasDiscount =>
      priceBeforeDiscount != null && priceBeforeDiscount! > unitPrice;

  /// True when adding one more would exceed what the shop has.
  bool get isAtMaxQuantity => stock != null && quantity >= stock!;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json.readInt('item_id') ?? 0,
    productId: json.readInt('item_product_id') ?? 0,
    name: json.readString('item_product_name') ?? '',
    quantity: json.readInt('item_quantity') ?? 1,
    unitPrice:
        json.readDouble('item_product_price_after_discount') ??
        json.readDouble('item_product_price') ??
        0,
    lineTotal: json.readDouble('item_total') ?? 0,
    image: json.readString('item_product_image'),
    priceBeforeDiscount: json.readDouble('item_product_price'),
    stock: json.readInt('item_product_stock'),
  );
}

/// The whole cart.
///
/// Every mutation endpoint (`/add-to-cart`, `/update-cart`,
/// `/remove-from-cart`) returns the full cart back, so the client never has to
/// recompute a total — it just replaces its state with the server's answer.
class CartModel {
  const CartModel({required this.items, required this.total, this.id});

  final List<CartItemModel> items;
  final double total;
  final int? id;

  bool get isEmpty => items.isEmpty;

  /// Total number of books, not lines — this is what the nav badge shows.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  const CartModel.empty() : items = const [], total = 0, id = null;

  /// An empty cart comes back as `{"cart_items": []}` with no `total` and no
  /// `id`, so every field beyond the list has to be optional.
  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    id: json.readInt('id'),
    items: json
        .readObjectList('cart_items')
        .map(CartItemModel.fromJson)
        .toList(),
    total: json.readDouble('total') ?? 0,
  );

  /// The item matching a cart line id, or null.
  CartItemModel? itemById(int itemId) {
    for (final item in items) {
      if (item.id == itemId) return item;
    }
    return null;
  }
}
