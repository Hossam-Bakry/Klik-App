import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/product_bid.dart';
import '../../domain/entities/product_color_option.dart';
import 'product_color_selector.dart';

/// What the customer did in the [showPriceNegotiateSheet] sheet.
sealed class NegotiateResult {
  const NegotiateResult();
}

/// Sent a new offer of [amount].
class NegotiateOfferSent extends NegotiateResult {
  const NegotiateOfferSent(this.amount);

  final double amount;
}

/// Tapped "Proceed to checkout" — buy at the price currently on the table.
class NegotiateCheckout extends NegotiateResult {
  const NegotiateCheckout();
}

/// "Price Negotiate" bottom sheet: the daily attempt allowance, the state of the
/// last offer, the prices in play, and the field to send a new offer.
///
/// Returns what the customer chose, or null if they dismissed the sheet.
Future<NegotiateResult?> showPriceNegotiateSheet(
  BuildContext context, {
  required ProductBid? bid,
  required double listedPrice,
  required String currency,
  required String productName,
  String productImage = '',
  String? sizeLabel,
  ProductColorOption? color,
}) {
  return showModalBottomSheet<NegotiateResult>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _PriceNegotiateSheet(
      bid: bid ?? const ProductBid(),
      listedPrice: listedPrice,
      currency: currency,
      productName: productName,
      productImage: productImage,
      sizeLabel: sizeLabel,
      color: color,
    ),
  );
}

class _PriceNegotiateSheet extends StatefulWidget {
  const _PriceNegotiateSheet({
    required this.bid,
    required this.listedPrice,
    required this.currency,
    required this.productName,
    required this.productImage,
    this.sizeLabel,
    this.color,
  });

  final ProductBid bid;
  final double listedPrice;
  final String currency;

  final String productName;
  final String productImage;

  /// The size/colour the customer picked on the product page, so the sheet
  /// shows exactly which variant is being negotiated. Null when the product
  /// has no such option.
  final String? sizeLabel;
  final ProductColorOption? color;

  @override
  State<_PriceNegotiateSheet> createState() => _PriceNegotiateSheetState();
}

class _PriceNegotiateSheetState extends State<_PriceNegotiateSheet> {
  final TextEditingController _amountController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  ProductBid get _bid => widget.bid;

  /// Lowest amount the seller will consider — `minimum_bid_amount` and
  /// `rules.minimum_bid_percentage` of the listed price, whichever is stricter.
  double? get _floor => _bid.minimumOfferFor(widget.listedPrice);

  /// Drops the seller's counter (or the suggestion) into the field, so the
  /// customer can accept it as-is or edit it down.
  void _fill(double price) {
    _amountController.text = price.toStringAsFixed(price % 1 == 0 ? 0 : 2);
    setState(() => _error = _validate(_amountController.text));
  }

  /// The error for [text], or null when it's a sendable offer. Empty input is
  /// silent — nothing to complain about until they type or send.
  String? _validate(String text) {
    final raw = text.trim();
    if (raw.isEmpty) return null;
    final amount = double.tryParse(raw);
    // Above the asking price isn't a negotiation; below the seller's floor is
    // the design's "too small" case.
    if (amount == null || amount <= 0 || amount >= widget.listedPrice) {
      return context.tr(LocaleKeys.bidInvalidAmount);
    }
    final floor = _floor;
    if (floor != null && amount < floor) {
      return context.tr(LocaleKeys.bidOfferTooSmall);
    }
    return null;
  }

  void _submit() {
    final raw = _amountController.text.trim();
    final error = raw.isEmpty
        ? context.tr(LocaleKeys.bidInvalidAmount)
        : _validate(raw);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(NegotiateOfferSent(double.parse(raw)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: context.r(16),
        right: context.r(16),
        top: context.r(8),
        // Clear the keyboard when the amount field is focused.
        bottom: context.r(16) + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHandle(),
          context.gapH(12),
          _title(context),
          context.gapH(16),
          _SelectedItemCard(
            name: widget.productName,
            image: widget.productImage,
            listedPrice: widget.listedPrice,
            currency: widget.currency,
            sizeLabel: widget.sizeLabel,
            color: widget.color,
          ),
          context.gapH(12),
          _LimitBar(
            bid: _bid,
            listedPrice: widget.listedPrice,
            currency: widget.currency,
          ),
          if (_bid.status != null) ...[
            context.gapH(12),
            _StatusBanner(
              bid: _bid,
              currency: widget.currency,
              onFill: _bid.isCountered && _bid.counteredPrice != null
                  ? () => _fill(_bid.counteredPrice!)
                  : null,
            ),
          ],
          ..._priceCards(context),
          // No point offering again while one is in review or already approved.
          if (_bid.canOffer) ...[
            context.gapH(12),
            _AmountField(
              controller: _amountController,
              currency: widget.currency,
              error: _error,
              minimum: _floor,
              onChanged: (text) => setState(() => _error = _validate(text)),
              onSubmit: _submit,
            ),
          ],
          // Only an approved, still-live price is buyable — every other state
          // is still being negotiated.
          if (_bid.hasLivePrice) ...[
            context.gapH(16),
            AppButton.filled(
              label: context.tr(LocaleKeys.proceedToCheckout),
              color: AppColors.primaryBronze,
              cornerRadius: 10,
              onPressed: () =>
                  Navigator.of(context).pop(const NegotiateCheckout()),
            ),
          ],
          context.gapH(16),
        ],
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Assets.icons.negotiationIcn.svg(
          width: context.r(26),
          height: context.r(26),
          colorFilter: const ColorFilter.mode(
            AppColors.primaryBronze,
            BlendMode.srcIn,
          ),
        ),
        context.gapW(8),
        Text(
          context.tr(LocaleKeys.priceNegotiate),
          style: context.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// The price card(s) for the current state: the seller's standing offer after
  /// a decline, the customer's own offer while pending or approved, and the
  /// suggestion whenever there's one to act on.
  ///
  /// A counter gets no card of its own — [_StatusBanner] already shows that
  /// price with its "Click to fill" shortcut, so the sheet goes straight from
  /// the banner to the amount field.
  List<Widget> _priceCards(BuildContext context) {
    final cards = <Widget>[];

    void add(Widget card) => cards.addAll([context.gapH(12), card]);

    final counter = _bid.counteredPrice;
    if (counter != null && _bid.isDeclined) {
      add(
        _OfferCard(
          title: context.tr(LocaleKeys.sellerOffer),
          price: counter,
          listedPrice: widget.listedPrice,
          currency: widget.currency,
          accent: AppColors.primaryBronze,
          footnote: _bid.offeredPrice == null
              ? null
              : '${context.tr(LocaleKeys.yourLastOffer)} : '
                    '${_money(_bid.offeredPrice!, widget.currency)}',
        ),
      );
    }

    if (_bid.hasLivePrice) {
      add(
        _OfferCard(
          title: context.tr(LocaleKeys.yourOffer),
          price: _bid.acceptedPrice!,
          listedPrice: widget.listedPrice,
          currency: widget.currency,
          accent: AppColors.success,
          strikeListedPrice: true,
        ),
      );
      // The deadline to buy sits under the card, not inside it.
      final until = _bid.expiresAt;
      if (until != null) add(_AvailableUntil(until: until));
    } else if (_bid.isPending && _bid.offeredPrice != null) {
      add(
        _OfferCard(
          title: context.tr(LocaleKeys.yourOffer),
          price: _bid.offeredPrice!,
          listedPrice: widget.listedPrice,
          currency: widget.currency,
          accent: AppColors.primaryBronze,
          footnote: context.tr(LocaleKeys.lastAcceptedOffer),
        ),
      );
    }

    final suggested = _bid.suggestedPrice;
    if (suggested != null && _bid.canOffer && !_bid.isCountered) {
      add(
        _SuggestedOfferCard(
          price: suggested,
          currency: widget.currency,
          onFill: () => _fill(suggested),
        ),
      );
    }

    return cards;
  }
}

String _money(double value, String currency) =>
    '${value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2)} '
    '$currency';

/// Percentage off the listed price, as the design's "7% Off" pill.
int _discountPercent(double price, double listedPrice) =>
    listedPrice <= 0 || price >= listedPrice
    ? 0
    : ((listedPrice - price) / listedPrice * 100).round();

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.r(44),
      height: context.r(4),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(context.r(4)),
      ),
    );
  }
}

/// "Selected Item": the product being negotiated — thumbnail, name, the listed
/// price, and the size/colour the customer picked — so the offer is never made
/// against a variant they've lost track of.
class _SelectedItemCard extends StatelessWidget {
  const _SelectedItemCard({
    required this.name,
    required this.image,
    required this.listedPrice,
    required this.currency,
    this.sizeLabel,
    this.color,
  });

  final String name;
  final String image;
  final double listedPrice;
  final String currency;
  final String? sizeLabel;
  final ProductColorOption? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.edgeAll(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(LocaleKeys.selectedItem),
            style: context.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          context.gapH(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImage(
                url: image,
                width: context.r(58),
                height: context.r(58),
                borderRadius: BorderRadius.circular(context.r(10)),
              ),
              context.gapW(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    context.gapH(6),
                    Text(
                      _money(listedPrice, currency),
                      style: context.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBronze,
                      ),
                    ),
                    ..._variants(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The picked variant chips. Nothing is rendered when the product has neither
  /// a size nor a colour to choose from.
  List<Widget> _variants(BuildContext context) {
    final chips = <Widget>[
      if (sizeLabel != null && sizeLabel!.trim().isNotEmpty)
        _VariantChip(
          label: '${context.tr(LocaleKeys.size)}: ${sizeLabel!}',
        ),
      if (color != null)
        _VariantChip(
          label: color!.name.trim().isEmpty
              ? context.tr(LocaleKeys.color)
              : '${context.tr(LocaleKeys.color)}: ${color!.name}',
          swatch: ProductColorSelector.parseHex(color!.hex),
        ),
    ];
    if (chips.isEmpty) return const [];
    return [
      context.gapH(8),
      Wrap(spacing: context.r(8), runSpacing: context.r(6), children: chips),
    ];
  }
}

/// Grey pill naming one picked variant, with an optional colour dot.
class _VariantChip extends StatelessWidget {
  const _VariantChip({required this.label, this.swatch});

  final String label;
  final Color? swatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.edgeSymmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.r(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (swatch != null) ...[
            Container(
              width: context.r(12),
              height: context.r(12),
              decoration: BoxDecoration(
                color: swatch,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
            ),
            context.gapW(6),
          ],
          Text(
            label,
            style: context.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Beige strip: today's bid allowance on the left, and on the right either the
/// countdown on a live offer or the product's real price when none is running.
class _LimitBar extends StatelessWidget {
  const _LimitBar({
    required this.bid,
    required this.listedPrice,
    required this.currency,
  });

  final ProductBid bid;
  final double listedPrice;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final exhausted = bid.attemptsLeft == 0;
    // The countdown only means something while an offer is live.
    final countdownUntil = bid.expiresAt != null && !bid.isExpired
        ? bid.expiresAt
        : null;

    return Container(
      width: double.infinity,
      padding: context.edgeSymmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBronze.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(context.r(12)),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.grey.shade200
          // )
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _limit(context, exhausted)),
              Container(
                width: 1,
                height: context.r(34),
                color: AppColors.textSecondary.withValues(alpha: 0.25),
              ),
              context.gapW(12),
              countdownUntil != null
                  ? _Countdown(until: countdownUntil)
                  : _realPrice(context),
            ],
          ),
          if (exhausted) ...[
            context.gapH(8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                context.tr(LocaleKeys.noAttemptsToday),
                style: context.labelSmall?.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _limit(BuildContext context, bool exhausted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(LocaleKeys.dailyBidLimit),
          style: context.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: exhausted
                ? AppColors.textPrimaryGold
                : AppColors.textPrimary,
          ),
        ),
        context.gapH(8),
        Row(
          children: [
            for (var i = 0; i < bid.dailyLimit; i++) ...[
              Container(
                width: context.r(18),
                height: context.r(6),
                decoration: BoxDecoration(
                  // Filled pills are attempts already spent today.
                  color: i < bid.attemptsUsed
                      ? AppColors.primaryBronze
                      : AppColors.textSecondary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(context.r(4)),
                ),
              ),
              context.gapW(4),
            ],
            context.gapW(4),
            Text(
              '${bid.attemptsUsed} / ${bid.dailyLimit}',
              style: context.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _realPrice(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          context.tr(LocaleKeys.realPrice),
          style: context.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        context.gapH(4),
        Text(
          _money(listedPrice, currency),
          style: context.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBronze,
          ),
        ),
      ],
    );
  }
}

/// "Expire in 08 : 42 : 53" — hour/minute/second chips ticking down to [until].
class _Countdown extends StatefulWidget {
  const _Countdown({required this.until});

  final DateTime until;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _timer;
  late Duration _left = _remaining();

  Duration _remaining() {
    final left = widget.until.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = _remaining();
      if (!mounted) return;
      setState(() => _left = left);
      if (left == Duration.zero) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final parts = [
      two(_left.inHours),
      two(_left.inMinutes.remainder(60)),
      two(_left.inSeconds.remainder(60)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: context.r(14),
              color: AppColors.primaryBronze,
            ),
            context.gapW(4),
            Text(
              context.tr(LocaleKeys.expireIn),
              style: context.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryGold,
              ),
            ),
          ],
        ),
        context.gapH(6),
        Row(
          children: [
            for (var i = 0; i < parts.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: context.edgeSymmetric(horizontal: 3),
                  child: Text(
                    ':',
                    style: context.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              Container(
                padding: context.edgeSymmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBronze.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(context.r(6)),
                ),
                child: Text(
                  parts[i],
                  style: context.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryGold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Tinted status strip: declined (red), countered (blue, with "Click to fill"),
/// approved (green), expired (grey) and pending (amber).
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.bid, required this.currency, this.onFill});

  final ProductBid bid;
  final String currency;

  /// Fills the amount field with the seller's counter (countered state only).
  final VoidCallback? onFill;

  @override
  Widget build(BuildContext context) {
    final status = bid.status!;
    final (statusColor, icon, iconColor, message) = switch (status) {
      BidStatus.pending => (
        AppColors.pendingStatusColor.withValues(alpha: 0.5),
        Icons.access_time_rounded,
        AppColors.primaryBronze,
        context.tr(LocaleKeys.bidPending),
      ),
      BidStatus.declined => (
        AppColors.rejectStatusColor.withValues(alpha: 0.05),
        Icons.cancel_outlined,
        AppColors.rejectStatusColor,
        context.tr(LocaleKeys.bidDeclined),
      ),
      BidStatus.countered => (
        AppColors.counterStatusColor.withValues(alpha: 0.5),
        Icons.sell_outlined,
        AppColors.primaryBronze,
        context.tr(LocaleKeys.bidCountered),
      ),
      BidStatus.approved => (
        AppColors.approvedStatusColor.withValues(alpha: 0.2),
        Icons.check_circle_outline_rounded,
        AppColors.success,
        context.tr(LocaleKeys.bidApproved),
      ),
      BidStatus.expired => (
        AppColors.expiredStatusColor,
        Icons.access_time_rounded,
        AppColors.textSecondary,
        context.tr(LocaleKeys.bidExpired),
      ),
    };
    return Container(
      width: double.infinity,
      padding: context.edgeAll(10),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(context.r(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: context.r(18), color: iconColor),
          context.gapW(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: context.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                ..._detail(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The price line under the message: the declined offer, or the counter with
  /// its "Click to fill" shortcut.
  List<Widget> _detail(BuildContext context) {
    if (bid.isDeclined && bid.offeredPrice != null) {
      return [
        context.gapH(6),
        Text(
          '${context.tr(LocaleKeys.yourOffer)} : '
          '${_money(bid.offeredPrice!, currency)}',
          style: context.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ];
    }
    if (bid.isCountered && bid.counteredPrice != null) {
      return [
        context.gapH(8),
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '${context.tr(LocaleKeys.counteredPrice)} : ',
                  style: context.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: _money(bid.counteredPrice!, currency),
                      style: context.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBronze,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onFill != null) _FillAction(onTap: onFill!),
          ],
        ),
      ];
    }
    return const [];
  }
}

/// "Click to fill" — copies a price into the amount field.
class _FillAction extends StatelessWidget {
  const _FillAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        context.tr(LocaleKeys.clickToFill),
        style: context.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBronze,
        ),
      ),
    );
  }
}

/// Bordered card showing one price in play (the seller's offer, or the
/// customer's own) with its discount pill and supporting lines.
class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.title,
    required this.price,
    required this.listedPrice,
    required this.currency,
    required this.accent,
    this.footnote,
    this.strikeListedPrice = false,
  });

  final String title;
  final double price;
  final double listedPrice;
  final String currency;

  /// Bronze for a pending/seller price, green once approved.
  final Color accent;

  /// Small line under the price, e.g. "Your last offer : 130 KWD".
  final String? footnote;

  /// Show `Listed Price : 150 KWD` struck through instead of [footnote].
  final bool strikeListedPrice;

  @override
  Widget build(BuildContext context) {
    final percent = _discountPercent(price, listedPrice);

    return Container(
      width: double.infinity,
      padding: context.edgeAll(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (percent > 0) _DiscountPill(percent: percent, color: accent),
            ],
          ),
          context.gapH(6),
          Text.rich(
            TextSpan(
              text: price % 1 == 0
                  ? price.toStringAsFixed(0)
                  : price.toStringAsFixed(2),
              style: context.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: accent,
              ),
              children: [
                TextSpan(
                  text: ' $currency',
                  style: context.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          context.gapH(4),
          if (strikeListedPrice)
            Text.rich(
              TextSpan(
                text: '${context.tr(LocaleKeys.listedPrice)} : ',
                style: context.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: _money(listedPrice, currency),
                    style: context.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            )
          else if (footnote != null)
            Text(
              footnote!,
              style: context.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// "Price available until  23 Jun · 11:47 PM" — the deadline to buy at an
/// approved price, centred under its offer card.
class _AvailableUntil extends StatelessWidget {
  const _AvailableUntil({required this.until});

  final DateTime until;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${context.tr(LocaleKeys.priceAvailableUntil)}  '
      '${DateFormat('d MMM').format(until)} · '
      '${DateFormat('h:mm a').format(until)}',
      textAlign: TextAlign.center,
      style: context.labelSmall?.copyWith(color: AppColors.textPrimaryGold),
    );
  }
}

/// Bronze "N% Off" pill, tinted to match the card it sits on.
class _DiscountPill extends StatelessWidget {
  const _DiscountPill({required this.percent, required this.color});

  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.edgeSymmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        context.tr(LocaleKeys.percentOff).replaceFirst('{count}', '$percent'),
        style: context.labelSmall?.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// The app's own suggestion, with a shortcut that fills it into the field.
class _SuggestedOfferCard extends StatelessWidget {
  const _SuggestedOfferCard({
    required this.price,
    required this.currency,
    required this.onFill,
  });

  final double price;
  final String currency;
  final VoidCallback onFill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.edgeAll(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Assets.icons.ideaIcn.svg(),
              // Icon(
              //   Icons.lightbulb_outline_rounded,
              //   size: context.r(18),
              //   color: AppColors.primaryBronze,
              // ),
              context.gapW(6),
              Expanded(
                child: Text(
                  context.tr(LocaleKeys.suggestedOffer),
                  style: context.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _FillAction(onTap: onFill),
            ],
          ),
          context.gapH(8),
          Text.rich(
            TextSpan(
              text: '${context.tr(LocaleKeys.suggestedOfferForYou)}  ',
              style: context.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: price % 1 == 0
                      ? price.toStringAsFixed(0)
                      : price.toStringAsFixed(2),
                  style: context.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBronze,
                  ),
                ),
                TextSpan(
                  text: ' $currency',
                  style: context.labelSmall?.copyWith(
                    color: AppColors.primaryBronze,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Your Negotiated Price": the amount field plus the bronze send button, in a
/// bordered block that turns red while [error] is set.
class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.currency,
    required this.onSubmit,
    required this.onChanged,
    this.error,
    this.minimum,
  });

  final TextEditingController controller;
  final String currency;
  final VoidCallback onSubmit;
  final ValueChanged<String> onChanged;
  final String? error;

  /// The seller's floor, shown as a hint so the rule is visible before the
  /// customer trips it. Null when the API set no minimum.
  final double? minimum;

  @override
  Widget build(BuildContext context) {
    final failed = error != null;
    final borderColor = failed
        ? AppColors.error
        : AppColors.textSecondary.withValues(alpha: 0.35);

    return Container(
      width: double.infinity,
      padding: context.edgeAll(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.20),
            blurRadius: context.r(2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(LocaleKeys.yourNegotiatedPrice),
            style: context.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryGold,
            ),
          ),
          context.gapH(10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,3}'),
                    ),
                  ],
                  onChanged: onChanged,
                  onSubmitted: (_) => onSubmit(),
                  style: TextStyle(
                    fontSize: context.sp(15),
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: context
                        .tr(LocaleKeys.offerAmountHint)
                        .replaceFirst('{currency}', currency),
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: context.sp(14),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: context.edgeSymmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    enabledBorder: _border(context, borderColor),
                    focusedBorder: _border(context, borderColor),
                    border: _border(context, borderColor),
                  ),
                ),
              ),
              context.gapW(10),
              _SendButton(onTap: onSubmit),
            ],
          ),
          if (failed) ...[
            context.gapH(6),
            Text(
              error!,
              style: context.labelSmall?.copyWith(color: AppColors.error),
            ),
          ] else if (minimum != null) ...[
            context.gapH(6),
            // Text(
            //   context
            //       .tr(LocaleKeys.bidMinimumOffer)
            //       .replaceFirst('{amount}', _money(minimum!, currency)),
            //   style: context.labelSmall?.copyWith(
            //     color: AppColors.textSecondary,
            //   ),
            // ),
          ],
        ],
      ),
    );
  }

  OutlineInputBorder _border(BuildContext context, Color color) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.r(10)),
        borderSide: BorderSide(color: color),
      );
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(10)),
      child: Container(
        width: context.r(48),
        height: context.r(46),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryBronze,
          borderRadius: BorderRadius.circular(context.r(10)),
        ),
        child: Icon(
          Icons.send_rounded,
          size: context.r(20),
          color: AppColors.surface,
        ),
      ),
    );
  }
}
