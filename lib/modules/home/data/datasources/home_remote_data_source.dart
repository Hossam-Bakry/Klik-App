import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/home_feed.dart';
import '../models/home_feed_dto.dart';

/// Talks to the network via [ApiInterface]. No try/catch here — envelope
/// unwrapping and error mapping live in the API client.
abstract class HomeRemoteDataSource {
  Future<ApiResult<HomeFeed>> fetchHomeFeed();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<HomeFeed>> fetchHomeFeed() => _api.get(
        ApiEndpoints.home,
        // Standard { message, data } envelope; client unwraps `data`.
        decoder: (data) => HomeFeedDto.fromJson(data as Map<String, dynamic>),
      );
}
