import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// "Payment Details" — the card form inside the payment step.
///
/// Deliberately local: no endpoint in this API accepts card data, so nothing
/// here is sent or stored. Applying just hands back a masked number for the
/// method row to display, and the card itself is dropped when the screen goes.
class PaymentDetailsForm extends StatefulWidget {
  const PaymentDetailsForm({super.key, required this.onApply});

  /// Receives the masked card number, e.g. "•••• 4242".
  final ValueChanged<String> onApply;

  @override
  State<PaymentDetailsForm> createState() => _PaymentDetailsFormState();
}

class _PaymentDetailsFormState extends State<PaymentDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  bool _cvvHidden = true;

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  void _apply() {
    if (!_formKey.currentState!.validate()) return;

    final digits = _number.text.replaceAll(RegExp(r'\D'), '');
    final last4 = digits.length < 4 ? digits : digits.substring(digits.length - 4);
    widget.onApply('•••• $last4');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(LocaleKeys.paymentDetails),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          context.gapH(12),
          Container(
            padding: context.edgeAll(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(context.r(10)),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _Field(
                  controller: _name,
                  label: context.tr(LocaleKeys.fullName),
                  textCapitalization: TextCapitalization.words,
                ),
                context.gapH(12),
                _Field(
                  controller: _number,
                  label: context.tr(LocaleKeys.cardNumber),
                  hint: '0000-0000-0000-0000',
                  keyboardType: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19),
                  ],
                  validator: (value) {
                    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                    return digits.length < 12
                        ? context.tr(LocaleKeys.invalidCardNumber)
                        : null;
                  },
                ),
                context.gapH(12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _expiry,
                        label: context.tr(LocaleKeys.expireDate),
                        hint: 'MM / YY',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ExpiryFormatter(),
                        ],
                        validator: (value) =>
                            (value ?? '').length < 5
                            ? context.tr(LocaleKeys.invalidExpiry)
                            : null,
                      ),
                    ),
                    context.gapW(12),
                    Expanded(
                      child: _Field(
                        controller: _cvv,
                        label: context.tr(LocaleKeys.cvv),
                        icon: Icons.lock_outline_rounded,
                        obscure: _cvvHidden,
                        keyboardType: TextInputType.number,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        suffix: GestureDetector(
                          onTap: () =>
                              setState(() => _cvvHidden = !_cvvHidden),
                          child: Icon(
                            _cvvHidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: context.r(18),
                            color: AppColors.textSecondary,
                          ),
                        ),
                        validator: (value) => (value ?? '').length < 3
                            ? context.tr(LocaleKeys.invalidCvv)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          context.gapH(20),
          AppButton.filled(
            label: context.tr(LocaleKeys.apply),
            cornerRadius: 10,
            onPressed: _apply,
          ),
        ],
      ),
    );
  }
}

/// Outlined field with its label floating on the border, as the design draws.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.suffix,
    this.obscure = false,
    this.keyboardType,
    this.formatters,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.r(8)),
      borderSide: BorderSide(color: AppColors.border),
    );

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      textCapitalization: textCapitalization,
      validator: validator,
      style: context.bodySmall,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        labelText: label,
        hintText: hint,
        labelStyle: context.labelSmall?.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: context.bodySmall?.copyWith(color: AppColors.textSecondary),
        prefixIcon: icon == null
            ? null
            : Icon(icon, size: context.r(18), color: AppColors.textSecondary),
        prefixIconConstraints: BoxConstraints(minWidth: context.r(38)),
        suffixIcon: suffix == null
            ? null
            : Padding(
                padding: context.edge(right: 10),
                child: suffix,
              ),
        suffixIconConstraints: BoxConstraints(minWidth: context.r(30)),
        contentPadding: context.edgeSymmetric(horizontal: 12, vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.primaryBronze),
        ),
      ),
    );
  }
}

/// Types the expiry as `MM / YY` while the customer enters digits.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final text = digits.length <= 2
        ? digits
        : '${digits.substring(0, 2)}/${digits.substring(2)}';

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
