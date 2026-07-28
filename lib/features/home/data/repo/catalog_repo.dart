import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/models/paginated.dart';
import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/features/home/data/models/slider_model.dart';
import 'package:bookia_app/features/home/data/services/catalog_service.dart';
import 'package:dio/dio.dart';

abstract interface class CatalogRepository {
  Future<ApiResult<List<SliderModel>>> sliders();
  Future<ApiResult<List<ProductModel>>> bestSellers();
  Future<ApiResult<List<ProductModel>>> newArrivals();
  Future<ApiResult<ProductModel>> product(int id);
  Future<ApiResult<Paginated<ProductModel>>> search({
    required String query,
    int page,
    CancelToken? cancelToken,
  });
}

class CatalogRepo implements CatalogRepository {
  const CatalogRepo(this._service);

  final CatalogService _service;

  @override
  Future<ApiResult<List<SliderModel>>> sliders() => _service.sliders();

  @override
  Future<ApiResult<List<ProductModel>>> bestSellers() => _service.bestSellers();

  @override
  Future<ApiResult<List<ProductModel>>> newArrivals() => _service.newArrivals();

  @override
  Future<ApiResult<ProductModel>> product(int id) => _service.product(id);

  @override
  Future<ApiResult<Paginated<ProductModel>>> search({
    required String query,
    int page = 1,
    CancelToken? cancelToken,
  }) => _service.search(query: query, page: page, cancelToken: cancelToken);
}
