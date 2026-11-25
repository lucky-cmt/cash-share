import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/user_entity.dart';

/// Data model for [UserEntity] with Supabase & JSON serialization.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.avatarUrl,
  });

  factory UserModel.fromSupabaseUser(supabase.User user) {
    final metadata = user.userMetadata;
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: metadata?['full_name'] as String? ??
          metadata?['name'] as String?,
      avatarUrl: metadata?['avatar_url'] as String? ??
          metadata?['picture'] as String?,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final meta = json['raw_user_meta_data'] as Map<String, dynamic>? ??
        json['user_metadata'] as Map<String, dynamic>?;

    return UserModel(
      id: (json['id'] ?? json['sub'] ?? '') as String,
      email: (json['email'] ?? meta?['email'] ?? '') as String,
      displayName: (json['display_name'] ??
          meta?['full_name'] ??
          meta?['name'] ??
          json['full_name'] ??
          json['name']) as String?,
      avatarUrl: (json['avatar_url'] ??
          meta?['avatar_url'] ??
          meta?['picture'] ??
          json['picture']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
    };
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
}
