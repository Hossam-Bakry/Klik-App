/// How a guest's cart is reconciled with the account's cart when a guest signs
/// in (see [CartCountCubit.onSignedIn]).
///
/// * [merge] — guest items are added on top of whatever the account already has
///   (the least-surprising default).
/// * [replace] — the guest cart overwrites the account's existing cart.
enum CartMergeStrategy {
  merge,
  replace;

  /// Wire value sent to the backend's merge endpoint.
  String get apiValue => name;
}
