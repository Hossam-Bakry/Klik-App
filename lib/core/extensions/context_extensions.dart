/// Barrel for all `BuildContext` extensions — import this one file to get
/// responsive sizing, edge insets, gaps, and localization from `context`:
///
/// ```dart
/// import 'package:klik_app/core/extensions/context_extensions.dart';
///
/// Padding(
///   padding: context.edgeAll(24),
///   child: Column(children: [
///     Text(context.tr(LocaleKeys.skip), style: TextStyle(fontSize: context.sp(16))),
///     context.gapH(12),
///     SizedBox(width: context.r(64), height: context.r(64)),
///   ]),
/// );
/// ```
library;

export 'edge_insets_extension.dart';
export 'gap_extension.dart';
export 'localization_extension.dart';
export 'size_extension.dart';
