import '../../../../core/network/api_result.dart';
import '../entities/home_feed.dart';

/// Contract the presentation layer depends on. Returns an [ApiResult] so the
/// BLoC switches over success/failure instead of try/catch.
abstract class HomeRepository {
  Future<ApiResult<HomeFeed>> getHomeFeed();
}
