import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../profile/presentation/widgets/photo_source_sheet.dart';
import '../../domain/entities/order_details.dart';
import '../cubit/write_review_cubit.dart';
import '../widgets/order_rating_stars.dart';

/// "Write a Review": the product being rated, a star strip, the comment (which
/// the endpoint requires), and optional photos.
///
/// Pops `true` once the review is posted so the order screen can refresh.
class WriteReviewPage extends StatefulWidget {
  const WriteReviewPage({
    super.key,
    required this.orderId,
    required this.product,
    this.initialRating,
  });

  final int orderId;
  final OrderLine product;
  final int? initialRating;

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  static const int _maxLength = 500;
  static const int _maxPhotos = 4;

  final TextEditingController _comment = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _photos = [];

  late int _rating = widget.initialRating ?? 0;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final source = await showPhotoSourceSheet(context);
    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (picked == null) return;
    setState(() => _photos.add(File(picked.path)));
  }

  Future<void> _submit() async {
    final comment = _comment.text.trim();
    setState(() {
      _error = switch (true) {
        _ when _rating == 0 => context.tr(LocaleKeys.pickARating),
        // The endpoint rejects an empty description, so catch it here rather
        // than round-tripping for a validation error.
        _ when comment.isEmpty => context.tr(LocaleKeys.reviewRequired),
        _ => null,
      };
    });
    if (_error != null) return;

    final sent = await context.read<WriteReviewCubit>().submit(
      orderId: widget.orderId,
      productId: widget.product.productId,
      rating: _rating,
      description: comment,
      photos: _photos,
    );
    if (!mounted || !sent) return;

    AppToast.success(context, context.tr(LocaleKeys.reviewSubmitted));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(
          context.tr(LocaleKeys.writeAReview),
          style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<WriteReviewCubit, WriteReviewState>(
        listenWhen: (p, c) =>
            c.errorMessage != null && p.errorMessage != c.errorMessage,
        listener: (context, state) =>
            AppToast.error(context, state.errorMessage!),
        builder: (context, state) {
          return ListView(
            padding: context.edge(left: 16, right: 16, top: 8, bottom: 24),
            children: [
              _productCard(context),
              context.gapH(12),
              _rateStrip(context),
              context.gapH(12),
              _reviewCard(context),
              if (_error != null) ...[
                context.gapH(8),
                Text(
                  _error!,
                  style: context.labelSmall?.copyWith(color: AppColors.error),
                ),
              ],
              context.gapH(20),
              AppButton.filled(
                label: context.tr(LocaleKeys.submitReview),
                cornerRadius: 10,
                isLoading: state.isSubmitting,
                onPressed: state.isSubmitting ? null : _submit,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _productCard(BuildContext context) {
    final product = widget.product;
    return Container(
      padding: context.edgeAll(10),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          AppNetworkImage(
            url: product.thumbnail,
            width: context.r(52),
            height: context.r(52),
            borderRadius: BorderRadius.circular(context.r(8)),
          ),
          context.gapW(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                context.gapH(4),
                Text(
                  '${product.effectivePrice.toStringAsFixed(2)} '
                  '${context.tr(LocaleKeys.currencyKwd)}',
                  style: context.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The peach "Rate ★★★★★" strip.
  Widget _rateStrip(BuildContext context) {
    return Container(
      padding: context.edgeSymmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryBronze.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(context.r(8)),
      ),
      child: Row(
        children: [
          Text(
            context.tr(LocaleKeys.rate),
            style: context.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          OrderRatingStars(
            rating: _rating,
            size: 30,
            onRated: (stars) => setState(() => _rating = stars),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(BuildContext context) {
    return Container(
      padding: context.edgeAll(14),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(LocaleKeys.yourReview),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          context.gapH(10),
          _commentField(context),
          context.gapH(16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                context.tr(LocaleKeys.addPhotos),
                style: context.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              context.gapW(4),
              Text(
                context.tr(LocaleKeys.optional),
                style: context.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          context.gapH(10),
          _photoTiles(context),
        ],
      ),
    );
  }

  /// The comment box with its own `0/500` counter in the bottom corner, as the
  /// design draws it (rather than Material's counter under the field).
  Widget _commentField(BuildContext context) {
    return Container(
      height: context.r(140),
      padding: context.edgeAll(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(10)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _comment,
              maxLines: null,
              expands: true,
              maxLength: _maxLength,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (_) => setState(() {}),
              style: context.bodySmall,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                counterText: '',
                hintText: context.tr(LocaleKeys.writeAReviewHint),
                hintStyle: context.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              '${_comment.text.characters.length}/$_maxLength',
              style: context.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Four slots: the photos picked so far, then a dashed "+" tile while there's
  /// room left.
  Widget _photoTiles(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _maxPhotos; i++) ...[
          if (i > 0) context.gapW(10),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: i < _photos.length
                  ? _PhotoThumb(
                      file: _photos[i],
                      onRemove: () => setState(() => _photos.removeAt(i)),
                    )
                  : _AddPhotoTile(
                      // Only the next free slot is tappable, so photos fill
                      // left to right.
                      onTap: i == _photos.length ? _addPhoto : null,
                    ),
            ),
          ),
        ],
      ],
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(context.r(10)),
    border: Border.all(color: AppColors.border),
  );
}

/// Empty photo slot — a dashed square with a "+".
class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            radius: context.r(8),
          ),
          child: Center(
            child: Icon(
              Icons.add,
              size: context.r(22),
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// A picked photo, with a corner button to drop it again.
class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.file, required this.onRemove});

  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(8));
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: radius,
          child: Image.file(file, fit: BoxFit.cover),
        ),
        PositionedDirectional(
          top: context.r(2),
          end: context.r(2),
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: context.edgeAll(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.55),
              ),
              child: Icon(
                Icons.close_rounded,
                size: context.r(14),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dashed rounded outline — Flutter has no dashed border, so it's painted.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final metric in outline.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dash),
          paint,
        );
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
