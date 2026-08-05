import 'package:equatable/equatable.dart';

import 'negotiation.dart';

/// The whole "My Negotiations" payload: the offers already bucketed by status,
/// with the per-bucket totals that fill the filter chips' badges.
///
/// `GET /api/bids` returns every bucket in one call, so the tabs are a local
/// filter — no request per chip.
class NegotiationBoard extends Equatable {
  const NegotiationBoard({
    this.groups = const {},
    this.counts = const {},
    this.total = 0,
  });

  /// Offers per status, in the order the API listed them.
  final Map<NegotiationStatus, List<Negotiation>> groups;

  /// `group_counts` — the server's own totals, which can exceed the number of
  /// rows on this page, so the chips stay truthful under pagination.
  final Map<NegotiationStatus, int> counts;

  /// `total` across every bucket.
  final int total;

  /// Every offer, newest first — what the "All" chip shows.
  List<Negotiation> get all {
    final merged = groups.values.expand((e) => e).toList()
      ..sort((a, b) {
        final at = a.submittedAt;
        final bt = b.submittedAt;
        if (at == null || bt == null) return 0;
        return bt.compareTo(at);
      });
    return merged;
  }

  List<Negotiation> of(NegotiationStatus? status) =>
      status == null ? all : (groups[status] ?? const []);

  /// Badge number for a chip. "All" ([status] null) prefers the server's
  /// [total]; falls back to the rows actually loaded.
  int countOf(NegotiationStatus? status) => status == null
      ? (total > 0 ? total : all.length)
      : (counts[status] ?? groups[status]?.length ?? 0);

  bool get isEmpty => all.isEmpty;

  @override
  List<Object?> get props => [groups, counts, total];
}
