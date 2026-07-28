import 'package:bookia_app/core/models/json_reader.dart';
import 'package:bookia_app/core/utils/html_text.dart';

/// A book.
///
/// The API returns four different shapes for what is conceptually the same
/// entity:
///   * `/products`, `/products-search`, `/products-filter` — the trimmed
///     resource: `price_after_discount`, `category` as a name;
///   * `/products/{id}` — the same plus `special`;
///   * `/products-bestseller`, `/products-new-arrivals` — the raw DB row:
///     `category_id`, `author`, `total_pages`, no `price_after_discount`;
///   * `/wishlist`, `/add-to-wishlist` — only `id`, `name`, `price`,
///     `category_name`, `image`.
///
/// [fromJson] reads all four, filling in what it can and leaving the rest
/// null, so one widget can render a book no matter which endpoint it came
/// from.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.image,
    this.category,
    this.author,
    this.discount = 0,
    this.priceAfterDiscount,
    this.stock,
    this.totalPages,
    this.isBestSeller = false,
  });

  final int id;
  final String name;

  /// List price before discount.
  final double price;

  final String? description;
  final String? image;

  /// Category *name*. The bestseller/new-arrivals shape only carries
  /// `category_id`, so this is null there.
  final String? category;

  /// Present only on the bestseller / new-arrivals shape.
  final String? author;

  /// Percentage, 0-100.
  final int discount;

  /// Sent by the trimmed resource; derived from [discount] otherwise.
  final double? priceAfterDiscount;

  /// Null on the wishlist shape, which omits it. Treated as "unknown, allow"
  /// rather than "zero, block" at the call sites.
  final int? stock;

  final int? totalPages;
  final bool isBestSeller;

  /// What the user actually pays.
  double get effectivePrice {
    final fromApi = priceAfterDiscount;
    if (fromApi != null && fromApi > 0) return fromApi;
    if (discount > 0 && discount < 100) return price * (100 - discount) / 100;
    return price;
  }

  bool get hasDiscount => effectivePrice < price;

  /// False only when the API told us the stock and it is zero.
  bool get isInStock => stock == null || stock! > 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // `price_after_discount` on the trimmed resource, absent on the raw row.
    final priceAfterDiscount = json.readDouble('price_after_discount');

    return ProductModel(
      id: json.readInt('id') ?? json.readInt('product_id') ?? 0,
      name: json.readString('name') ?? json.readString('product_name') ?? '',
      price: json.readDouble('price') ?? json.readDouble('product_price') ?? 0,
      // The API stores descriptions as HTML; strip it here so no screen has
      // to think about markup.
      description: HtmlText.strip(
        json.readString('description') ??
            json.readString('product_description'),
      ),
      image: json.readString('image') ?? json.readString('product_image'),
      // `category` on the resource, `category_name` on the wishlist shape.
      category: json.readString('category') ?? json.readString('category_name'),
      author: json.readString('author'),
      discount:
          json.readInt('discount') ?? json.readInt('product_discount') ?? 0,
      priceAfterDiscount: priceAfterDiscount,
      stock: json.readInt('stock') ?? json.readInt('product_stock'),
      totalPages: json.readInt('total_pages'),
      // `best_seller` is a rank, not a flag: 0 means "not a best seller",
      // any positive number is a position in the list.
      isBestSeller: (json.readInt('best_seller') ?? 0) > 0,
    );
  }

  static List<ProductModel> listFrom(List<Map<String, dynamic>> items) =>
      items.map(ProductModel.fromJson).toList();

  ProductModel copyWith({int? stock}) => ProductModel(
    id: id,
    name: name,
    price: price,
    description: description,
    image: image,
    category: category,
    author: author,
    discount: discount,
    priceAfterDiscount: priceAfterDiscount,
    stock: stock ?? this.stock,
    totalPages: totalPages,
    isBestSeller: isBestSeller,
  );

  @override
  bool operator ==(Object other) => other is ProductModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
