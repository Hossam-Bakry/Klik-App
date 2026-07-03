import 'dart:io';

import '../../../../core/network/api_result.dart';
import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  /// 🔒 GET /api/profile — the signed-in user's current profile.
  Future<ApiResult<UserProfile>> getProfile();

  /// 🔒 POST /api/update-profile. Pass [photoFile] to upload a new photo
  /// (multipart — the API validates it as an image file); omit it to leave
  /// the current photo untouched.
  Future<ApiResult<UserProfile>> updateProfile(
    UserProfile profile, {
    File? photoFile,
  });
}
