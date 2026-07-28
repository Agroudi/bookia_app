import 'package:bookia_app/core/api/api_client.dart';
import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/core/utils/html_text.dart';
import 'package:bookia_app/features/cart/data/models/cart_model.dart';
import 'package:bookia_app/features/orders/data/models/order_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Parsing tests for the four different product shapes the API returns, and
/// for the fields whose types vary between endpoints. These are the places a
/// change on the server would break the app silently, so they are worth
/// pinning down.
void main() {
  group('ProductModel', () {
    test('parses the trimmed /products resource', () {
      final product = ProductModel.fromJson({
        'id': 1,
        'name': 'nostrum',
        'description': 'Est est quia vel.',
        'price': '378.00',
        'discount': 22,
        'price_after_discount': 294.84000000000003,
        'stock': 42,
        'best_seller': 0,
        'image': 'http://example.com/product-1.webp',
        'category': 'praesentium',
      });

      expect(product.id, 1);
      // price arrives as a string here and as a number elsewhere.
      expect(product.price, 378.0);
      expect(product.effectivePrice, closeTo(294.84, 0.01));
      expect(product.hasDiscount, isTrue);
      expect(product.isBestSeller, isFalse);
      expect(product.isInStock, isTrue);
    });

    test('parses the raw /products-bestseller row', () {
      final product = ProductModel.fromJson({
        'id': 3,
        'category_id': 1,
        'name': 'ut',
        'author': 'Guillermo Kessler',
        'total_pages': 290,
        'price': '147.00',
        'stock': 34,
        'discount': 95,
        // A rank, not a boolean.
        'best_seller': 100,
      });

      expect(product.author, 'Guillermo Kessler');
      expect(product.totalPages, 290);
      expect(product.isBestSeller, isTrue);
      // No price_after_discount on this shape, so it is derived.
      expect(product.effectivePrice, closeTo(7.35, 0.01));
      expect(product.category, isNull);
    });

    test('parses the minimal /wishlist shape', () {
      final product = ProductModel.fromJson({
        'id': 1,
        'name': 'rem',
        'price': '371.00',
        'category_name': 'dolores',
        'image': 'http://example.com/product-2.webp',
      });

      expect(product.category, 'dolores');
      expect(product.effectivePrice, 371.0);
      // Stock is absent, which must read as "unknown, allow" not "sold out".
      expect(product.stock, isNull);
      expect(product.isInStock, isTrue);
    });

    test('survives a payload with every field missing', () {
      final product = ProductModel.fromJson(const {});

      expect(product.id, 0);
      expect(product.name, isEmpty);
      expect(product.price, 0);
      expect(product.isInStock, isTrue);
    });
  });

  group('CartModel', () {
    test('parses a populated cart', () {
      final cart = CartModel.fromJson({
        'id': 1,
        'total': '294.84',
        'cart_items': [
          {
            'item_id': 1,
            'item_product_id': 1,
            'item_product_name': 'nostrum',
            'item_product_price': '378.00',
            'item_product_price_after_discount': 294.84000000000003,
            'item_product_stock': 42,
            'item_quantity': 2,
            'item_total': 589.68,
          },
        ],
      });

      expect(cart.items, hasLength(1));
      expect(cart.total, closeTo(294.84, 0.01));
      expect(cart.itemCount, 2);
      // item_id is the handle for update/remove — not item_product_id.
      expect(cart.itemById(1)?.productId, 1);
      expect(cart.itemById(99), isNull);
      expect(cart.items.first.isAtMaxQuantity, isFalse);
    });

    test('parses the empty-cart response, which omits id and total', () {
      final cart = CartModel.fromJson({'cart_items': <dynamic>[]});

      expect(cart.isEmpty, isTrue);
      expect(cart.total, 0);
      expect(cart.itemCount, 0);
    });

    test('flags an item that has reached available stock', () {
      final cart = CartModel.fromJson({
        'cart_items': [
          {'item_id': 1, 'item_quantity': 5, 'item_product_stock': 5},
        ],
      });

      expect(cart.items.first.isAtMaxQuantity, isTrue);
    });
  });

  group('Order models', () {
    test('reads per_page whether it is an int or a string', () {
      // /products returns an int, /products-filter returns a string.
      final asInt = OrderSummary.pageFrom({
        'orders': <dynamic>[],
        'meta': {'total': 4, 'per_page': 15, 'current_page': 1, 'last_page': 1},
      });
      final asString = OrderSummary.pageFrom({
        'orders': <dynamic>[],
        'meta': {
          'total': 4,
          'per_page': '2',
          'current_page': 1,
          'last_page': 2,
        },
      });

      expect(asInt.meta.perPage, 15);
      expect(asString.meta.perPage, 2);
      expect(asInt.hasMore, isFalse);
      expect(asString.hasMore, isTrue);
    });

    test('picks the governorate name for the active language', () {
      final governorate = GovernorateModel.fromJson(const {
        'id': 1,
        'governorate_name_ar': 'القاهرة',
        'governorate_name_en': 'Cairo',
      });

      expect(governorate.nameFor('ar'), 'القاهرة');
      expect(governorate.nameFor('en'), 'Cairo');
    });

    test('falls back to the other language when one name is blank', () {
      final governorate = GovernorateModel.fromJson(const {
        'id': 2,
        'governorate_name_ar': '',
        'governorate_name_en': 'Giza',
      });

      expect(governorate.nameFor('ar'), 'Giza');
    });

    test('parses order details including line items', () {
      final order = OrderDetails.fromJson({
        'id': 52,
        'order_code': '00052',
        'total': '594.03',
        'sub_total': '594.03',
        'order_date': '2023-08-14',
        'status': 'New',
        'governorate': 'Menofia',
        'tax': null,
        'discount': 0,
        'order_products': [
          {
            'product_id': 2,
            'product_name': 'doloremque',
            'product_price': '421.00',
            'product_price_after_discount': 130.51,
            'order_product_quantity': 3,
            'product_total': '391.53',
          },
        ],
      });

      expect(order.code, '00052');
      expect(order.itemCount, 3);
      expect(order.products.first.unitPrice, closeTo(130.51, 0.01));
      expect(order.tax, isNull);
    });
  });

  group('HtmlText', () {
    test('strips the markup the API wraps descriptions in', () {
      const html =
          '<p>Master the math needed to excel in data science, machine&nbsp;'
          'learning.</p>';
      expect(
        HtmlText.strip(html),
        'Master the math needed to excel in data science, machine learning.',
      );
    });

    test('keeps paragraph breaks and decodes entities', () {
      const html = '<p>First &amp; foremost.</p><p>Second&#8217;s turn.</p>';
      expect(HtmlText.strip(html), 'First & foremost.\n\nSecond’s turn.');
    });

    test('returns null for null or markup-only input', () {
      expect(HtmlText.strip(null), isNull);
      expect(HtmlText.strip('<p></p>'), isNull);
    });

    test('product descriptions come through already stripped', () {
      final product = ProductModel.fromJson(const {
        'id': 1,
        'name': 'x',
        'price': '1.00',
        'description': '<p>Plain <b>enough</b>.</p>',
      });
      expect(product.description, 'Plain enough.');
    });
  });

  group('Parse.listMaybeNested', () {
    // The API returns collections three different ways depending on endpoint.
    const item = {'id': 1, 'name': 'x', 'price': '1.00'};

    test('reads a bare list', () {
      final list = Parse.listMaybeNested([item], Parse.productListKeys);
      expect(list, hasLength(1));
    });

    test(
      'reads a list nested under "products" (bestseller / new arrivals)',
      () {
        final list = Parse.listMaybeNested({
          'products': [item],
        }, Parse.productListKeys);
        expect(list, hasLength(1));
      },
    );

    test(
      'reads a Laravel paginator, where items sit under "data" (/wishlist)',
      () {
        final list = Parse.listMaybeNested({
          'current_page': 1,
          'data': [item],
          'per_page': 15,
          'total': 1,
        }, Parse.productListKeys);
        expect(list, hasLength(1));
        expect(ProductModel.fromJson(list.first).id, 1);
      },
    );

    test('degrades to empty rather than throwing on an unknown shape', () {
      expect(
        Parse.listMaybeNested({'unexpected': 1}, Parse.productListKeys),
        isEmpty,
      );
      expect(Parse.listMaybeNested(null, Parse.productListKeys), isEmpty);
    });
  });
}
