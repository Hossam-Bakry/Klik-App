import 'package:flutter/widgets.dart';

import 'size_extension.dart';

/// Responsive [EdgeInsets] from context. All sides use the single uniform
/// scale factor, so padding keeps its design proportions on every device.
extension ResponsiveEdgeInsets on BuildContext {
  EdgeInsets edgeAll(double value) => EdgeInsets.all(r(value));

  EdgeInsets edge({
    double top = 0,
    double bottom = 0,
    double left = 0,
    double right = 0,
  }) =>
      EdgeInsets.only(
        top: r(top),
        bottom: r(bottom),
        left: r(left),
        right: r(right),
      );

  EdgeInsets edgeHorizontal(double horizontal) =>
      EdgeInsets.symmetric(horizontal: r(horizontal));

  EdgeInsets edgeVertical(double vertical) =>
      EdgeInsets.symmetric(vertical: r(vertical));

  EdgeInsets edgeSymmetric({double vertical = 0, double horizontal = 0}) =>
      EdgeInsets.symmetric(
        vertical: r(vertical),
        horizontal: r(horizontal),
      );
}
