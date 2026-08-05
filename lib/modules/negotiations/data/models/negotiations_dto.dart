import '../../domain/entities/negotiation.dart';
import '../../domain/entities/negotiation_board.dart';

/// Parses the `GET /api/bids` `data` object into a [NegotiationBoard].
///
/// The payload arrives pre-bucketed: `groups` maps a status to its rows, and
/// `group_counts` carries each bucket's server-side total. Each row pairs the
/// product (`product_id`, `name`, `thumbnail`) with the offer under `bid`.
///
/// Throwing on bad JSON is fine — DioApiClient turns decode errors into a
/// ParsingFailure.
class NegotiationsDto {
  const NegotiationsDto._();

  static NegotiationBoard fromJson(Map<String, dynamic> data) {
    final rawGroups = data[_K.groups] as Map? ?? const {};
    final rawCounts = data[_K.groupCounts] as Map? ?? const {};

    final groups = <NegotiationStatus, List<Negotiation>>{};
    for (final entry in rawGroups.entries) {
      final status = NegotiationStatus.parse(_str(entry.key));
      // An unknown bucket (a status the app doesn't model yet) is skipped
      // rather than crashing the screen.
      if (status == null) continue;
      final rows = (entry.value as List? ?? const [])
          .whereType<Map>()
          .map((e) => _rowFromJson(e.cast<String, dynamic>(), status))
          .toList();
      if (rows.isNotEmpty) groups[status] = rows;
    }

    final counts = <NegotiationStatus, int>{};
    for (final entry in rawCounts.entries) {
      final status = NegotiationStatus.parse(_str(entry.key));
      if (status != null) counts[status] = _toInt(entry.value);
    }

    return NegotiationBoard(
      groups: groups,
      counts: counts,
      total: _toInt(data[_K.total]),
    );
  }

  /// One `groups[status][]` entry. [group] is the bucket it came from, used as
  /// the status when the row's own `bid.status` is missing or unrecognised.
  static Negotiation _rowFromJson(
    Map<String, dynamic> json,
    NegotiationStatus group,
  ) {
    final bid = json[_K.bid] as Map? ?? const {};
    final price = bid[_K.price] as Map? ?? const {};
    final variant = bid[_K.variant] as Map?;

    // An `active` price is a deal on the table; `amount` is meaningless without
    // it (a rejected row can still carry a stale amount).
    final active = _toBool(price[_K.priceActive]);
    final amount = _toNullableDouble(price[_K.priceAmount]);

    return Negotiation(
      bidId: _toInt(bid[_K.id]),
      productId: _toInt(json[_K.productId]),
      name: _str(json[_K.name]),
      thumbnail: _str(json[_K.thumbnail]),
      status: NegotiationStatus.parse(_str(bid[_K.status])) ?? group,
      bidAmount: _toDouble(price[_K.bidAmount]),
      listedPrice: _toDouble(price[_K.listedPrice]),
      variantLabel: _str(variant?[_K.variantLabel]),
      counterAmount: _toNullableDouble(price[_K.counterAmount]),
      agreedAmount: active ? amount : null,
      expiresAt: DateTime.tryParse(_str(price[_K.expiresAt]))?.toLocal(),
      isExpired: _toBool(price[_K.expired]),
      submittedAt: DateTime.tryParse(_str(bid[_K.submittedAt]))?.toLocal(),
    );
  }

  // --- Coercion helpers ------------------------------------------------------

  static String _str(Object? v) => v?.toString().trim() ?? '';

  static double _toDouble(Object? v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  /// Keeps "absent" distinct from 0 — a counter of 0 KWD is meaningless, a
  /// missing one just isn't shown.
  static double? _toNullableDouble(Object? v) =>
      v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

  static int _toInt(Object? v) => switch (v) {
    num n => n.toInt(),
    String s => int.tryParse(s) ?? 0,
    _ => 0,
  };

  static bool _toBool(Object? v) =>
      v == true || v == 1 || v == '1' || v.toString().toLowerCase() == 'true';
}

/// Backend JSON keys, isolated so a schema change is a one-place edit.
class _K {
  // Envelope
  static const total = 'total';
  static const groups = 'groups';
  static const groupCounts = 'group_counts';

  // Row
  static const productId = 'product_id';
  static const name = 'name';
  static const thumbnail = 'thumbnail';

  // Row → bid
  static const bid = 'bid';
  static const id = 'id';
  static const status = 'status';
  static const submittedAt = 'submitted_at';
  static const variant = 'variant';
  static const variantLabel = 'label';

  // Row → bid → price
  static const price = 'price';
  static const bidAmount = 'bid_amount';
  static const counterAmount = 'counter_amount';
  static const listedPrice = 'listed_price';
  static const priceActive = 'active';
  static const priceAmount = 'amount';
  static const expiresAt = 'expires_at';
  static const expired = 'expired';
}
