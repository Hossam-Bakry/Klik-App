import '../../../../core/localization/locale_keys.dart';

/// The payment options the design offers.
///
/// The choice is presentation-only for now: nothing in the API accepts card
/// data, no endpoint lists the gateways a shop supports, and `place-order`
/// takes no payment field — the backend applies its own default. Only [cash]
/// can actually be honoured today; the rest say so when picked.
enum PaymentMethod {
  card(LocaleKeys.debitCreditCard),
  applePay(LocaleKeys.applePay),
  googlePay(LocaleKeys.googlePay),
  knet(LocaleKeys.knet),
  tabby(LocaleKeys.tabby, subtitleKey: LocaleKeys.tabbyInstallments),
  cash(LocaleKeys.cashOnDelivery);

  const PaymentMethod(this.labelKey, {this.subtitleKey});

  final String labelKey;
  final String? subtitleKey;

  /// Whether an order can go through on it. Everything but cash needs a
  /// gateway the app hasn't been given.
  bool get isAvailable => this == cash;

  /// Reads the server's `payment_method` — the orders payload carries one, but
  /// its vocabulary isn't documented, so match loosely (`cash_on_delivery`,
  /// `Cash On Delivery`, `COD` … all land on [cash]). Null when it says nothing
  /// recognisable, which lets the caller fall back to what the customer picked.
  static PaymentMethod? fromApi(String? value) {
    final v = value?.toLowerCase().replaceAll(RegExp('[^a-z]'), '') ?? '';
    if (v.isEmpty) return null;
    if (v.contains('cash') || v == 'cod') return cash;
    if (v.contains('knet')) return knet;
    if (v.contains('apple')) return applePay;
    if (v.contains('google')) return googlePay;
    if (v.contains('tabby')) return tabby;
    if (v.contains('card') || v.contains('credit') || v.contains('debit')) {
      return card;
    }
    return null;
  }
}
