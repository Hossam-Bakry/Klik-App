import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
/// Cases: [AppTextField.text], [AppTextField.name], [AppTextField.email],
/// [AppTextField.password] (with show/hide toggle), [AppTextField.phone]
/// (with an embedded [CountryCodePicker]).
class AppTextField extends StatefulWidget {
  const AppTextField._({
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isPassword = false,
    this.country,
    this.onCountryChanged,
  });

  /// Generic single-line field.
  const AppTextField.text({
    Key? key,
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) : this._(
          controller: controller,
          hint: hint,
          prefixIcon: prefixIcon,
          keyboardType: keyboardType,
          validator: validator,
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

  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;
  final Country? country;
  final ValueChanged<Country>? onCountryChanged;

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

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(12));
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return TextFormField(
      controller: widget.controller,
      validator: (value) => _validate(context, value),
      keyboardType: widget.keyboardType,
      inputFormatters: _formatters,
      obscureText: widget.isPassword && _obscured,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(fontSize: context.sp(15), color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: context.sp(15),
        ),
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, color: AppColors.primary, size: context.r(22)),
        suffixIcon: _buildSuffix(context),
        contentPadding:
            context.edgeSymmetric(horizontal: 16, vertical: 16),
        enabledBorder: border(const Color(0xFFE6E0D4)),
        focusedBorder: border(AppColors.primary, 1.4),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, 1.4),
      ),
    );
  }

  Widget? _buildSuffix(BuildContext context) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textSecondary,
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
    return null;
  }
}
