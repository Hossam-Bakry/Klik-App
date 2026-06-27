// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/app_icon.png
  AssetGenImage get appIcon => const AssetGenImage('assets/icons/app_icon.png');

  /// File path: assets/icons/apple_icn.svg
  SvgGenImage get appleIcn => const SvgGenImage('assets/icons/apple_icn.svg');

  /// File path: assets/icons/cart_icn.svg
  SvgGenImage get cartIcn => const SvgGenImage('assets/icons/cart_icn.svg');

  /// File path: assets/icons/category_icn.svg
  SvgGenImage get categoryIcn =>
      const SvgGenImage('assets/icons/category_icn.svg');

  /// File path: assets/icons/delivery_icn.svg
  SvgGenImage get deliveryIcn =>
      const SvgGenImage('assets/icons/delivery_icn.svg');

  /// File path: assets/icons/google_icn.svg
  SvgGenImage get googleIcn => const SvgGenImage('assets/icons/google_icn.svg');

  /// File path: assets/icons/home_icn.svg
  SvgGenImage get homeIcn => const SvgGenImage('assets/icons/home_icn.svg');

  /// File path: assets/icons/money_dollar_icn.svg
  SvgGenImage get moneyDollarIcn =>
      const SvgGenImage('assets/icons/money_dollar_icn.svg');

  /// File path: assets/icons/negotiation_icn.svg
  SvgGenImage get negotiationIcn =>
      const SvgGenImage('assets/icons/negotiation_icn.svg');

  /// File path: assets/icons/notification_icn.svg
  SvgGenImage get notificationIcn =>
      const SvgGenImage('assets/icons/notification_icn.svg');

  /// File path: assets/icons/profile_icn.svg
  SvgGenImage get profileIcn =>
      const SvgGenImage('assets/icons/profile_icn.svg');

  /// File path: assets/icons/search_icn.svg
  SvgGenImage get searchIcn => const SvgGenImage('assets/icons/search_icn.svg');

  /// File path: assets/icons/selected_favorite_icn.svg
  SvgGenImage get selectedFavoriteIcn =>
      const SvgGenImage('assets/icons/selected_favorite_icn.svg');

  /// File path: assets/icons/truck_icn.svg
  SvgGenImage get truckIcn => const SvgGenImage('assets/icons/truck_icn.svg');

  /// File path: assets/icons/un_selected_favorite_icn.svg
  SvgGenImage get unSelectedFavoriteIcn =>
      const SvgGenImage('assets/icons/un_selected_favorite_icn.svg');

  /// List of all assets
  List<dynamic> get values => [
    appIcon,
    appleIcn,
    cartIcn,
    categoryIcn,
    deliveryIcn,
    googleIcn,
    homeIcn,
    moneyDollarIcn,
    negotiationIcn,
    notificationIcn,
    profileIcn,
    searchIcn,
    selectedFavoriteIcn,
    truckIcn,
    unSelectedFavoriteIcn,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/auth_background_imag.png
  AssetGenImage get authBackgroundImag =>
      const AssetGenImage('assets/images/auth_background_imag.png');

  /// File path: assets/images/forget_password_img.png
  AssetGenImage get forgetPasswordImg =>
      const AssetGenImage('assets/images/forget_password_img.png');

  /// File path: assets/images/on_boarding_one_img.png
  AssetGenImage get onBoardingOneImg =>
      const AssetGenImage('assets/images/on_boarding_one_img.png');

  /// File path: assets/images/on_boarding_two_img.png
  AssetGenImage get onBoardingTwoImg =>
      const AssetGenImage('assets/images/on_boarding_two_img.png');

  /// File path: assets/images/otp_img.png
  AssetGenImage get otpImg => const AssetGenImage('assets/images/otp_img.png');

  /// File path: assets/images/splash_img.png
  AssetGenImage get splashImg =>
      const AssetGenImage('assets/images/splash_img.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    authBackgroundImag,
    forgetPasswordImg,
    onBoardingOneImg,
    onBoardingTwoImg,
    otpImg,
    splashImg,
  ];
}

class $AssetsLangGen {
  const $AssetsLangGen();

  /// File path: assets/lang/ar.json
  String get ar => 'assets/lang/ar.json';

  /// File path: assets/lang/en.json
  String get en => 'assets/lang/en.json';

  /// List of all assets
  List<String> get values => [ar, en];
}

class Assets {
  const Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLangGen lang = $AssetsLangGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
