import 'package:equatable/equatable.dart';

import 'banner_item.dart';
import 'category_item.dart';
import 'home_product.dart';
import 'shop_item.dart';

/// The whole home screen payload (`GET /api/home`) as one domain object. The
/// BLoC holds this; each section reads its slice.
class HomeFeed extends Equatable {
  const HomeFeed({
    required this.banners,
    required this.categories,
    required this.justForYou,
    required this.shops,
    required this.bidableProducts,
  });

  final List<BannerItem> banners;
  final List<CategoryItem> categories;

  /// "Best deals for you".
  final List<HomeProduct> justForYou;
  final List<ShopItem> shops;

  /// "Open to offers" — products whose sellers accept negotiation.
  final List<HomeProduct> bidableProducts;

  /// A dummy feed used to lay out skeleton bones while the real data loads.
  factory HomeFeed.placeholder() {
    final products = List.generate(
      6,
      (i) => const HomeProduct(
        id: 0,
        name: 'Samsung washing machine',
        thumbnail: '',
        price: 22,
        discountPrice: 19,
        discountPercentage: 20,
        rating: 4.5,
        totalSold: 113,
        quantity: 1,
        isFavorite: false,
        isBidable: true,
        shopName: 'Klik Store',
        estimatedDeliveryTime: '2',
      ),
    );
    return HomeFeed(
      banners: const [BannerItem(id: 0, title: '', thumbnail: '')],
      categories: List.generate(
        6,
        (i) => const CategoryItem(id: 0, name: 'Category', thumbnail: ''),
      ),
      justForYou: products,
      shops: List.generate(
        6,
        (i) => const ShopItem(
          id: 0,
          name: 'Shop',
          logo: '',
          rating: 0,
          totalProducts: 0,
          isOnline: true,
        ),
      ),
      bidableProducts: products,
    );
  }

  @override
  List<Object?> get props => [banners, categories, justForYou, shops, bidableProducts];
}
