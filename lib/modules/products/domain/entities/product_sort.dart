import 'package:flutter/material.dart';

import '../../../../core/localization/locale_keys.dart';

/// Sort options for `GET /api/products` (`sort_by` query param). "Default
/// sorting" is the absence of a sort (null), so it isn't a member here.
///
/// The `apiValue`s are the full set the backend accepts:
/// `top_selling | popular_product | newest | just_for_you | high_to_low |
/// low_to_high`.
enum ProductSort {
  newest('newest', LocaleKeys.sortNewProducts, Icons.access_time_rounded),
  priceHighToLow('high_to_low', LocaleKeys.sortHighToLow, Icons.south_rounded),
  priceLowToHigh('low_to_high', LocaleKeys.sortLowToHigh, Icons.north_rounded),
  bestSelling('top_selling', LocaleKeys.sortBestSelling, Icons.local_fire_department_outlined),
  popular('popular_product', LocaleKeys.sortMostPopular, Icons.star_rounded),
  justForYou('just_for_you', LocaleKeys.sortJustForYou, Icons.favorite_border_rounded);

  const ProductSort(this.apiValue, this.labelKey, this.icon);

  final String apiValue;
  final String labelKey;
  final IconData icon;
}
