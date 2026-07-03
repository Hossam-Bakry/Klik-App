import 'dart:io';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<ApiResult<UserProfile>> getProfile() => _remote.getProfile();

  @override
  Future<ApiResult<UserProfile>> updateProfile(
    UserProfile profile, {
    File? photoFile,
  }) => _remote.updateProfile(profile, photoFile: photoFile);
}
