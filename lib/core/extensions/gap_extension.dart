import 'package:flutter/widgets.dart';

import 'size_extension.dart';

/// Responsive spacing widgets from context — replaces the old WGap/HGap.
///
/// `context.gapH(16)` ≈ 16 design-px tall; `context.gapW(8)` ≈ 8 wide. Both
/// scale uniformly via [ResponsiveSize].
extension GapExtension on BuildContext {
  /// Vertical gap.
  Widget gapH(double height) => SizedBox(height: r(height));

  /// Horizontal gap.
  Widget gapW(double width) => SizedBox(width: r(width));
}
