import 'package:bookia_app/core/models/json_reader.dart';
import 'package:bookia_app/core/models/paginated.dart';

/// A row in Order History.
class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.code,
    required this.date,
    required this.status,
    required this.total,
  });

  final int id;

  /// Zero-padded display code, e.g. `00051`.
  final String code;

  /// `YYYY-MM-DD` as sent by the API. Kept as a string because the design
  /// shows it verbatim and the API sends no timezone.
  final String date;

  final String status;
  final double total;

  factory OrderSummary.fromJson(Map<String, dynamic> json) => OrderSummary(
    id: json.readInt('id') ?? 0,
    code: json.readString('order_code') ?? '',
    date: json.readString('order_date') ?? '',
    status: json.readString('status') ?? '',
    total: json.readDouble('total') ?? 0,
  );

  static Paginated<OrderSummary> pageFrom(Map<String, dynamic> data) =>
      Paginated(
        items: data
            .readObjectList('orders')
            .map(OrderSummary.fromJson)
            .toList(),
        meta: PaginationMeta.fromJson(data.readObject('meta')),
      );
}

/// A book within an order.
class OrderProduct {
  const OrderProduct({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.discount = 0,
  });

  final int productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final int discount;

  factory OrderProduct.fromJson(Map<String, dynamic> json) => OrderProduct(
    productId: json.readInt('product_id') ?? 0,
    name: json.readString('product_name') ?? '',
    quantity: json.readInt('order_product_quantity') ?? 1,
    unitPrice:
        json.readDouble('product_price_after_discount') ??
        json.readDouble('product_price') ??
        0,
    lineTotal: json.readDouble('product_total') ?? 0,
    discount: json.readInt('product_discount') ?? 0,
  );
}

/// `/order-history/{id}` — the full record.
class OrderDetails {
  const OrderDetails({
    required this.id,
    required this.code,
    required this.date,
    required this.status,
    required this.total,
    required this.subTotal,
    required this.products,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.governorate,
    this.notes,
    this.rejectDetails,
    this.tax,
    this.discount = 0,
  });

  final int id;
  final String code;
  final String date;
  final String status;
  final double total;
  final double subTotal;
  final List<OrderProduct> products;

  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? governorate;
  final String? notes;

  /// Why the shop rejected the order, when it did.
  final String? rejectDetails;

  final double? tax;
  final int discount;

  int get itemCount =>
      products.fold(0, (sum, product) => sum + product.quantity);

  factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
    id: json.readInt('id') ?? 0,
    code: json.readString('order_code') ?? '',
    date: json.readString('order_date') ?? '',
    status: json.readString('status') ?? '',
    total: json.readDouble('total') ?? 0,
    subTotal: json.readDouble('sub_total') ?? 0,
    products: json
        .readObjectList('order_products')
        .map(OrderProduct.fromJson)
        .toList(),
    name: json.readString('name'),
    email: json.readString('email'),
    phone: json.readString('phone'),
    address: json.readString('address'),
    governorate: json.readString('governorate'),
    notes: json.readString('notes'),
    rejectDetails: json.readString('reject_details'),
    tax: json.readDouble('tax'),
    discount: json.readInt('discount') ?? 0,
  );
}

/// A delivery governorate, used by the Place Order picker.
class GovernorateModel {
  const GovernorateModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  final int id;
  final String nameAr;
  final String nameEn;

  /// The name in the user's language, falling back to the other when one side
  /// is missing from the data.
  String nameFor(String languageCode) {
    final preferred = languageCode == 'ar' ? nameAr : nameEn;
    if (preferred.isNotEmpty) return preferred;
    return languageCode == 'ar' ? nameEn : nameAr;
  }

  factory GovernorateModel.fromJson(Map<String, dynamic> json) =>
      GovernorateModel(
        id: json.readInt('id') ?? 0,
        nameAr: json.readString('governorate_name_ar') ?? '',
        nameEn: json.readString('governorate_name_en') ?? '',
      );
}

/// `/checkout` — the order summary shown before submitting, plus whatever the
/// server already knows about the user so the form can prefill.
class CheckoutModel {
  const CheckoutModel({
    required this.total,
    required this.itemCount,
    this.name,
    this.phone,
    this.address,
  });

  final double total;
  final int itemCount;
  final String? name;
  final String? phone;
  final String? address;

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    final user = json.readObject('user') ?? const {};
    final items = json.readObjectList('cart_items');

    return CheckoutModel(
      total: json.readDouble('total') ?? 0,
      itemCount: items.fold(
        0,
        (sum, item) => sum + (item.readInt('item_quantity') ?? 0),
      ),
      name: user.readString('user_name'),
      phone: user.readString('phone'),
      address: user.readString('address'),
    );
  }
}
