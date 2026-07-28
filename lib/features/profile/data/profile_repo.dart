import 'package:bookia_app/core/api/api_client.dart';
import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/models/json_reader.dart';
import 'package:bookia_app/core/models/user_model.dart';
import 'package:bookia_app/core/storage/app_storage.dart';
import 'package:dio/dio.dart';

/// A question/answer pair from `/faqs`.
class FaqModel {
  const FaqModel({required this.question, required this.answer});

  final String question;
  final String answer;

  factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
    question: json.readString('question') ?? '',
    answer: json.readString('answer') ?? '',
  );
}

class ProfileService {
  const ProfileService(this._client);

  final ApiClient _client;

  Future<ApiResult<UserModel>> profile() => _client.get(
    ApiConstants.profile,
    parse: (data) => UserModel.fromJson(Parse.object(data)),
  );

  /// [imagePath] is a local file path from the picker; when present the whole
  /// request switches to multipart, which is the only way to send the avatar.
  Future<ApiResult<UserModel>> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? city,
    String? imagePath,
  }) {
    final fields = <String, dynamic>{
      ApiKeys.name: name,
      if (phone != null && phone.isNotEmpty) ApiKeys.phone: phone,
      if (address != null && address.isNotEmpty) ApiKeys.address: address,
      if (city != null && city.isNotEmpty) ApiKeys.city: city,
    };

    UserModel parse(Object? data) => UserModel.fromJson(Parse.object(data));

    if (imagePath == null) {
      return _client.post(
        ApiConstants.updateProfile,
        body: fields,
        parse: parse,
      );
    }

    return _client.postForm(
      ApiConstants.updateProfile,
      fields: {...fields, ApiKeys.image: MultipartFile.fromFileSync(imagePath)},
      parse: parse,
    );
  }

  /// Form-encoded, per the collection.
  Future<ApiResult<UserModel>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) => _client.postForm(
    ApiConstants.updatePassword,
    fields: {
      ApiKeys.currentPassword: currentPassword,
      ApiKeys.newPassword: newPassword,
      ApiKeys.newPasswordConfirmation: newPasswordConfirmation,
    },
    parse: (data) => UserModel.fromJson(Parse.object(data)),
  );

  Future<ApiResult<void>> deleteAccount(String currentPassword) =>
      _client.postForm(
        ApiConstants.deleteProfile,
        fields: {ApiKeys.currentPassword: currentPassword},
        parse: Parse.unit,
      );

  Future<ApiResult<List<FaqModel>>> faqs() => _client.get(
    ApiConstants.faqs,
    parse: (data) => Parse.object(
      data,
    ).readObjectList('faqs').map(FaqModel.fromJson).toList(),
  );

  Future<ApiResult<void>> contactUs({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) => _client.postForm(
    ApiConstants.contactUs,
    fields: {
      ApiKeys.name: name,
      ApiKeys.email: email,
      ApiKeys.subject: subject,
      ApiKeys.message: message,
    },
    parse: Parse.unit,
  );
}

abstract interface class ProfileRepository {
  UserModel? get cachedUser;
  Future<ApiResult<UserModel>> profile();
  Future<ApiResult<UserModel>> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? city,
    String? imagePath,
  });
  Future<ApiResult<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
  Future<ApiResult<void>> deleteAccount(String currentPassword);
  Future<ApiResult<List<FaqModel>>> faqs();
  Future<ApiResult<void>> contactUs({
    required String name,
    required String email,
    required String subject,
    required String message,
  });
}

class ProfileRepo implements ProfileRepository {
  const ProfileRepo({
    required ProfileService service,
    required SessionStorage storage,
  }) : _service = service,
       _storage = storage;

  final ProfileService _service;
  final SessionStorage _storage;

  @override
  UserModel? get cachedUser {
    final json = _storage.cachedUser;
    return json == null ? null : UserModel.fromJson(json);
  }

  @override
  Future<ApiResult<UserModel>> profile() async =>
      _cacheUser(await _service.profile());

  @override
  Future<ApiResult<UserModel>> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? city,
    String? imagePath,
  }) async => _cacheUser(
    await _service.updateProfile(
      name: name,
      phone: phone,
      address: address,
      city: city,
      imagePath: imagePath,
    ),
  );

  @override
  Future<ApiResult<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final result = await _service.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
    return switch (result) {
      ApiSuccess(:final message) => ApiSuccess(null, message: message),
      ApiFailure(:final failure) => ApiFailure(failure),
    };
  }

  @override
  Future<ApiResult<void>> deleteAccount(String currentPassword) async {
    final result = await _service.deleteAccount(currentPassword);
    // The account is gone server-side; the local session must go with it.
    if (result.isSuccess) await _storage.clearSession();
    return result;
  }

  @override
  Future<ApiResult<List<FaqModel>>> faqs() => _service.faqs();

  @override
  Future<ApiResult<void>> contactUs({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) => _service.contactUs(
    name: name,
    email: email,
    subject: subject,
    message: message,
  );

  /// Keeps the offline copy in step so the Profile screen paints instantly on
  /// the next cold start.
  Future<ApiResult<UserModel>> _cacheUser(ApiResult<UserModel> result) async {
    if (result case ApiSuccess(:final data)) {
      await _storage.saveUser(data.toJson());
    }
    return result;
  }
}
