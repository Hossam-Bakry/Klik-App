import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_dto.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ApiResult<UserProfile>> getProfile();

  /// [photoFile], when set, is uploaded as multipart — the API validates
  /// `profile_photo` as an actual image file (jpg/jpeg/png/svg/webp/gif), not
  /// a URL. Omit it to leave the current photo untouched.
  Future<ApiResult<UserProfile>> updateProfile(
    UserProfile profile, {
    File? photoFile,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<UserProfile>> getProfile() => _api.get(
    ApiEndpoints.profile,
    decoder: (data) => UserProfileDto.fromJson(data),
  );

  @override
  Future<ApiResult<UserProfile>> updateProfile(
    UserProfile profile, {
    File? photoFile,
  }) async {
    final fields = <String, dynamic>{
      'name': profile.name,
      'phone': profile.phone,
      'country_iso': profile.countryIso,
      'country_code': profile.countryCode,
      'email': profile.email,
      if (profile.gender != null) 'gender': profile.gender,
      if (profile.dateOfBirth != null) 'date_of_birth': profile.dateOfBirth,
    };

    final Object body;
    if (photoFile != null) {
      body = FormData.fromMap({
        ...fields,
        'profile_photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.uri.pathSegments.last,
        ),
      });
    } else {
      body = fields;
    }

    return _api.post(
      ApiEndpoints.updateProfile,
      body: body,
      decoder: (data) => UserProfileDto.fromJson(data),
    );
  }
}
