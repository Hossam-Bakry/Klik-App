import '../../../../core/network/api_result.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

/// The home feed is already mapped to domain entities by [HomeFeedDto], so this
/// is a thin pass-through. Kept as a seam for caching/merging later.
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  @override
  Future<ApiResult<HomeFeed>> getHomeFeed() => _remote.fetchHomeFeed();
}
