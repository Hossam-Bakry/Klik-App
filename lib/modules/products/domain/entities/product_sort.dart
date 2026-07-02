/// Sort options for `GET /api/products` (`sort_type` query param).
///
/// PROVISIONAL: only [popular] (`popular_product`) is confirmed from the API
/// example. The other `apiValue`s are best-guess conventions — reconcile them
/// against the backend; this enum is the single place to edit.
enum ProductSort {
  popular('popular_product'),
  newest('newest'),
  priceLowToHigh('price_low_to_high'),
  priceHighToLow('price_high_to_low'),
  topRated('top_rated');

  const ProductSort(this.apiValue);

  final String apiValue;
}
