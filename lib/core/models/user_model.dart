import 'package:bookia_app/core/models/json_reader.dart';

/// The authenticated user, as returned by `/login`, `/register`, `/profile`
/// and the password endpoints — the shape is identical across all of them.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.address,
    this.city,
    this.phone,
    this.image,
    this.isEmailVerified = false,
  });

  final int id;
  final String name;
  final String email;
  final String? address;
  final String? city;
  final String? phone;
  final String? image;
  final bool isEmailVerified;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json.readInt('id') ?? 0,
    name: json.readString('name') ?? '',
    email: json.readString('email') ?? '',
    address: json.readString('address'),
    city: json.readString('city'),
    phone: json.readString('phone'),
    image: json.readString('image'),
    isEmailVerified: json.readBool('email_verified'),
  );

  /// Round-trips through [SessionStorage] so the profile screen can paint
  /// immediately on a cold start instead of waiting on `/profile`.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'address': address,
    'city': city,
    'phone': phone,
    'image': image,
    'email_verified': isEmailVerified,
  };
}

/// `/login` and `/register` wrap the user alongside a token.
class AuthPayload {
  const AuthPayload({required this.user, required this.token});

  final UserModel user;
  final String token;

  factory AuthPayload.fromJson(Map<String, dynamic> json) => AuthPayload(
    user: UserModel.fromJson(json.readObject('user') ?? const {}),
    token: json.readString('token') ?? '',
  );
}
