/// Catalog of customer API endpoints (`/api/*`), transcribed from the Postman
/// collection "Klik Copy". Paths are relative to [ApiConstants.baseUrl].
///
/// 🔒 = requires `Authorization: Bearer <token>` (added automatically by
/// [AuthInterceptor]). Methods/bodies are noted in comments for reference.
///
/// Seller (`/api/seller/*`) and rider (`/api/rider/*`) endpoints are omitted —
/// this is the customer app.
class ApiEndpoints {
  const ApiEndpoints._();

  // ---------------------------------------------------------------------------
  // Auth & account
  // ---------------------------------------------------------------------------
  /// POST — body: { phone, password, country_iso, country_code }
  /// → data.access.token
  static const String login = '/api/login';

  /// POST — body: { name, email, password, phone, country, country_code,
  ///                 country_iso, gender }
  static const String registration = '/api/registration';

  /// POST — body: { phone, country_code, country_iso }  (sends an OTP)
  static const String sendOtp = '/api/send-otp';

  /// POST — body: { phone, otp, country_iso, country_code }
  static const String verifyOtp = '/api/verify-otp';

  /// POST — body: { otp, phone, country_iso, country_code }
  static const String verifyPhoneOtp = '/api/verify-phone-otp';

  /// POST — body: { token, password, password_confirmation }
  static const String resetPassword = '/api/reset-password';

  /// 🔒 POST — body: { current_password, password, password_confirmation }
  static const String changePassword = '/api/change-password';

  /// POST — body: { name, email, phone, auth_type, id, profile_url, gender }
  static const String socialAuth = '/api/social-auth';

  /// POST — body: { code }. Provider is a path param (e.g. google).
  static String socialAuthToken(String provider) => '/api/auth/$provider/token';

  /// 🔒 POST
  static const String logout = '/api/logout';

  /// 🔒 GET — current user
  static const String profile = '/api/profile';

  /// 🔒 POST — body: { name, phone, country_iso, country_code, email,
  ///                   profile_photo }
  static const String updateProfile = '/api/update-profile';

  // ---------------------------------------------------------------------------
  // Home & catalog (public)
  // ---------------------------------------------------------------------------
  static const String home = '/api/home';
  static const String master = '/api/master';
  static const String banners = '/api/banners';
  static const String categories = '/api/categories';
  static const String subCategories = '/api/sub-categories'; // ?category_id=
  static const String shopCategories = '/api/shop-categories'; // ?shop_id=
  static const String products = '/api/products';
  static const String categoryProducts = '/api/category-products';
  static const String productDetails = '/api/product-details'; // ?product_id=
  static const String recentlyViews = '/api/recently-views';
  static const String reviews = '/api/reviews';
  static const String countries = '/api/countries';

  // Flash sales
  static const String flashSales = '/api/flash-sales';
  static String flashSaleDetails(Object id) => '/api/flash-sale/$id/details';

  // Blog & legal
  static const String blogs = '/api/blogs';
  static String blogDetails(Object id) => '/api/blog/$id/details';
  static const String contactUs = '/api/contact-us';
  static String legalPage(String slug) => '/api/legal-pages/$slug';
  static String translations(String locale) => '/api/lang/$locale';

  // ---------------------------------------------------------------------------
  // Shops
  // ---------------------------------------------------------------------------
  static const String shops = '/api/shops';
  static const String topShops = '/api/shops/top';
  static const String popularProducts = '/api/shops/popular-products';
  static String shopDetails(Object shop) => '/api/shops/$shop';

  // ---------------------------------------------------------------------------
  // Addresses 🔒
  // ---------------------------------------------------------------------------
  static const String addresses = '/api/addresses';
  static const String addressStore = '/api/address/store';
  static String addressUpdate(Object id) => '/api/address/$id/update';
  static String addressDelete(Object id) => '/api/address/$id/delete';

  // ---------------------------------------------------------------------------
  // Cart 🔒
  // ---------------------------------------------------------------------------
  static const String carts = '/api/carts';
  static const String cartStore = '/api/cart/store';
  static const String cartIncrement = '/api/cart/increment';
  static const String cartDecrement = '/api/cart/decrement';
  static const String cartDelete = '/api/cart/delete';
  static const String cartCheckout = '/api/cart/checkout';

  // ---------------------------------------------------------------------------
  // Orders 🔒
  // ---------------------------------------------------------------------------
  static const String orders = '/api/orders';
  static const String orderDetails = '/api/order-details'; // ?order_id=
  static const String placeOrder = '/api/place-order';
  static const String placeOrderV1 = '/api/v1/place-order';
  static const String reOrder = '/api/place-order/again';
  static const String cancelOrder = '/api/orders/cancel';
  static String orderPayment(Object order, Object method) =>
      '/api/order-payment/$order/$method';

  // ---------------------------------------------------------------------------
  // Coupons & vouchers 🔒
  // ---------------------------------------------------------------------------
  static const String applyVoucher = '/api/apply-voucher';
  static const String couponsApply = '/api/coupons/apply';
  static const String getVouchers = '/api/get-vouchers'; // ?shop_id=&coupon_id=
  static const String collectedVouchers = '/api/get-collected-vouchers';
  static const String collectVoucher = '/api/vouchers-collect';

  // ---------------------------------------------------------------------------
  // Products: favorites, reviews, bids 🔒
  // ---------------------------------------------------------------------------
  static const String favoriteProducts = '/api/favorite-products';
  static const String favoriteToggle = '/api/favorite-add-or-remove';
  static const String productReview = '/api/product-review';
  static const String bids = '/api/bids';

  // ---------------------------------------------------------------------------
  // Support 🔒 (support submit is public)
  // ---------------------------------------------------------------------------
  static const String support = '/api/support';
  static const String supportTickets = '/api/support-tickets';
  static const String supportTicket = '/api/support-ticket';
  static const String supportTicketShow = '/api/support-ticket/show';
  static const String supportTicketMessage = '/api/support-ticket-message';
  static const String supportTicketMessages = '/api/support-ticket-messages';
  static const String ticketIssueTypes = '/api/ticket-issue-types';
}
