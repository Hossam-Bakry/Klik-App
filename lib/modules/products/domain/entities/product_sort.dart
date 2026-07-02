import 'package:flutter/material.dart';

import '../../../../core/localization/locale_keys.dart';

/// Sort options for `GET /api/products` (`sort_type` query param). "Default
/// sorting" is the absence of a sort (null), so it isn't a member here.
///
/// PROVISIONAL: only [popular] (`popular_product`) is confirmed from the API
/// example. The other `apiValue`s are best-guess conventions — reconcile them
/// against the backend; this enum is the single place to edit.
enum ProductSort {
  newest('newest', LocaleKeys.sortNewProducts, Icons.access_time_rounded),
  priceHighToLow('price_high_to_low', LocaleKeys.sortHighToLow, Icons.south_rounded),
  priceLowToHigh('price_low_to_high', LocaleKeys.sortLowToHigh, Icons.north_rounded),
  bestSelling('best_selling', LocaleKeys.sortBestSelling, Icons.local_fire_department_outlined),
  popular('popular_product', LocaleKeys.sortMostPopular, Icons.star_rounded);

  const ProductSort(this.apiValue, this.labelKey, this.icon);

  final String apiValue;
  final String labelKey;
  final IconData icon;
}
