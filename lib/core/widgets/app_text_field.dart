import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../constants/countries.dart';
import '../constants/validators.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import 'country_code_picker.dart';

/// One reusable form field for the whole app. Each input type is a named
/// constructor that redirects to the private constructor with the right
/// keyboard, prefix icon, and behaviour — add a new case by adding another
/// named constructor rather than configuring flags at call sites.
///
/// Cases: [AppTextField.text], [AppTextField.search], [AppTextField.name],
/// [AppTextField.email], [AppTextField.password] (with show/hide toggle),
/// [AppTextField.phone] (with an embedded [CountryCodePicker]),
/// [AppTextField.multiline] (multi-row, with a character counter).
///
/// Any case may pass a [decoration] to fully replace the default
/// [InputDecoration] when the surface needs a bespoke look.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;
  final Country? country;
  final ValueChanged<Country>? onCountryChanged;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;

  const AppTextField._({
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isPassword = false,
    this.country,
    this.onCountryChanged,
    this.onChanged,
    this.decoration,
    this.isSearch = false,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
  });

  /// Generic single-line field.
  const AppTextField.text({
    Key? key,
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    InputDecoration? decoration,
  }) : this._(
         controller: controller,
         hint: hint,
         prefixIcon: prefixIcon,
         keyboardType: keyboardType,
         validator: validator,
         onChanged: onChanged,
         decoration: decoration,
       );

  /// Search field with a leading search icon. Pass [onChanged] to react to
  /// query changes as the user types.
  const AppTextField.search({
    Key? key,
    required TextEditingController controller,
    required String hint,
    ValueChanged<String>? onChanged,
    InputDecoration? decoration,
    bool autofocus = false,
  }) : this._(
         controller: controller,
         hint: hint,
         suffixIcon: Icons.search,
         onChanged: onChanged,
         decoration: decoration,
         isSearch: true,
         autofocus: autofocus,
       );

  const AppTextField.name({
    Key? key,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) : this._(
         controller: controller,
         hint: hint,
         prefixIcon: Icons.person_outline,
         keyboardType: TextInputType.name,
         validator: validator,
       );

  const AppTextField.email({
    Key? key,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) : this._(
         controller: controller,
         hint: hint,
         prefixIcon: Icons.mail_outline,
         keyboardType: TextInputType.emailAddress,
         validator: validator,
       );

  const AppTextField.password({
    Key? key,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) : this._(
         controller: controller,
         hint: hint,
         prefixIcon: Icons.lock_outline,
         validator: validator,
         isPassword: true,
       );

  /// Phone field with an embedded country-code picker as the suffix.
  const AppTextField.phone({
    Key? key,
    required TextEditingController controller,
    required String hint,
    required Country country,
    required ValueChanged<Country> onCountryChanged,
    String? Function(String?)? validator,
  }) : this._(
         controller: controller,
         hint: hint,
         prefixIcon: Icons.phone_outlined,
         keyboardType: TextInputType.phone,
         validator: validator,
         country: country,
         onCountryChanged: onCountryChanged,
       );

  /// Fixed-height, multi-row field ([lines] tall) with a `current/max`
  /// character counter (e.g. a support message or review comment).
  const AppTextField.multiline({
    Key? key,
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    int lines = 5,
    IconData? prefixIcon = Icons.chat_outlined,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) : this._(
         controller: controller,
         hint: hint,
         prefixIcon: prefixIcon,
         keyboardType: TextInputType.multiline,
         validator: validator,
         onChanged: onChanged,
         maxLines: lines,
         maxLength: maxLength,
       );

  /// When non-null, fully replaces the default [InputDecoration]. The hint and
  /// prefix/suffix icons baked into the case are still applied on top of it so
  /// callers only override what they care about (colors, borders, fill).
  final InputDecoration? decoration;

  /// Set by [AppTextField.search] to pick the pill-shaped, borderless default
  /// decoration instead of the bordered one.
  final bool isSearch;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  bool get _isPhone => widget.country != null;

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the user switches to a country with a shorter number, trim any
    // now-too-long input so the field stays valid. Deferred to after the frame
    // because mutating the controller here notifies the Form mid-build.
    final maxLen = widget.country?.phoneLength;
    if (maxLen != null && widget.controller.text.length > maxLen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.controller.text.length <= maxLen) return;
        final trimmed = widget.controller.text.substring(0, maxLen);
        widget.controller.value = TextEditingValue(
          text: trimmed,
          selection: TextSelection.collapsed(offset: trimmed.length),
        );
      });
    }
  }

  /// For phone fields: required + no leading zero + exact national length for
  /// the country (see [Validators.phone]). Other fields use their own validator.
  String? _validate(BuildContext context, String? value) {
    if (!_isPhone) return widget.validator?.call(value);
    return Validators.phone(context, widget.country!)(value);
  }

  List<TextInputFormatter>? get _formatters {
    if (_isPhone) {
      return [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.country!.phoneLength),
      ];
    }
    // Cap password length at the source so an oversized payload can never be
    // typed or pasted in (see [Validators.passwordMaxLength]).
    if (widget.isPassword) {
      return [LengthLimitingTextInputFormatter(Validators.passwordMaxLength)];
    }
    return null;
  }

  /// Pill-shaped, borderless decoration used by [AppTextField.search].
  InputDecoration _searchDecoration(BuildContext context) {
    final radius = BorderRadius.circular(context.r(50));
    OutlineInputBorder border() =>
        OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none);
    return InputDecoration(
      hintStyle: context.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: context.edgeSymmetric(horizontal: 16, vertical: 14),
      enabledBorder: border(),
      focusedBorder: border(),
      border: border(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(12));
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    final prefixIcon = widget.prefixIcon == null
        ? null
        : Icon(
            widget.prefixIcon,
            color: AppColors.primary,
            size: context.r(22),
          );
    // Multiline: the built-in `prefixIcon` slot is always vertically centered
    // across the *whole* decorator by Flutter's InputDecorator, regardless of
    // padding put inside it — so nudging it with Padding/Align never actually
    // moves it to the top. Handled separately below with a manual Stack
    // overlay instead of the decoration's prefixIcon.
    final isMultiline = widget.maxLines > 1;
    final prefix = isMultiline ? null : prefixIcon;

    final suffix = widget.suffixIcon == null
        ? null
        : Icon(
            widget.suffixIcon,
            color: AppColors.primary,
            size: context.r(22),
          );

    // Default look, unless the caller supplied a custom decoration to build on.
    // The case's hint and prefix/suffix icons are layered on top so callers
    // only override the bits they care about (colors, borders, fill).
    final base =
        widget.decoration ??
        (widget.isSearch
            ? _searchDecoration(context)
            : InputDecoration(
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.sp(15),
                ),
                filled: true,
                fillColor: AppColors.surface,
                // Multiline reserves extra left space for the manually
                // overlaid icon (see below) instead of using the decoration's
                // prefixIcon slot.
                contentPadding: EdgeInsets.only(
                  left: context.r(isMultiline && prefixIcon != null ? 44 : 16),
                  right: context.r(16),
                  top: context.r(16),
                  bottom: context.r(16),
                ),
                enabledBorder: border(const Color(0xFFE6E0D4)),
                focusedBorder: border(AppColors.primary, 1.4),
                errorBorder: border(AppColors.error),
                focusedErrorBorder: border(AppColors.error, 1.4),
              ));

    final field = TextFormField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      validator: (value) => _validate(context, value),
      keyboardType: widget.keyboardType,
      inputFormatters: _formatters,
      obscureText: widget.isPassword && _obscured,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      textAlignVertical: isMultiline ? TextAlignVertical.top : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(fontSize: context.sp(15), color: AppColors.textPrimary),
      decoration: base.copyWith(
        hintText: widget.hint,
        alignLabelWithHint: isMultiline,
        prefixIcon: prefix,
        suffixIcon: _buildSuffix(context),
        counterStyle: TextStyle(
          fontSize: context.sp(12),
          color: AppColors.textSecondary,
        ),
      ),
    );

    if (!isMultiline || prefixIcon == null) return field;

    // Manual top-left overlay: Flutter's InputDecorator always vertically
    // centers the decoration's `prefixIcon` slot across the whole field, so
    // for a tall multiline box that reads as "centered" no matter how the
    // icon inside that slot is padded/aligned. A Stack sidesteps that.
    return Stack(
      children: [
        field,
        Positioned(
          top: context.r(16),
          left: context.r(14),
          child: IgnorePointer(child: prefixIcon),
        ),
      ],
    );
  }

  Widget? _buildSuffix(BuildContext context) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.primaryBronze,
          size: context.r(22),
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }
    if (widget.country != null && widget.onCountryChanged != null) {
      return Padding(
        padding: context.edge(right: 12, left: 8),
        child: CountryCodePicker(
          selected: widget.country!,
          onChanged: widget.onCountryChanged!,
        ),
      );
    }

    if (widget.suffixIcon != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Assets.icons.searchIcn.svg(),
      );
    }
    return null;
  }
}
