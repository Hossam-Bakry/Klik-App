import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/countries.dart';
import '../../../../core/constants/validators.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/address.dart';
import '../bloc/address_bloc.dart';
import '../widgets/address_map_picker.dart';
import '../widgets/address_type_selector.dart';

/// Add (when [address] is null) or edit an address. The map header captures the
/// current location and auto-fills the form; Save persists via [AddressBloc]
/// and pops on success.
class AddEditAddressPage extends StatefulWidget {
  const AddEditAddressPage({super.key, this.address});

  final Address? address;

  bool get isEditing => address != null;

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _area;
  late final TextEditingController _flatNumber;
  late final TextEditingController _postCode;
  late final TextEditingController _line1;
  late final TextEditingController _line2;

  late Country _country;
  late AddressType _type;
  late bool _isDefault;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _fullName = TextEditingController(text: a?.fullName);
    _phone = TextEditingController(text: a?.phone);
    _city = TextEditingController(text: a?.city);
    _area = TextEditingController(text: a?.area);
    _flatNumber = TextEditingController(text: a?.flatNumber);
    _postCode = TextEditingController(text: a?.postCode);
    _line1 = TextEditingController(text: a?.line1);
    _line2 = TextEditingController(text: a?.line2);
    _type = a?.type ?? AddressType.home;
    _isDefault = a?.isDefault ?? false;
    _lat = a?.lat;
    _lng = a?.lng;
    _country = a == null
        ? Countries.defaultCountry
        : Countries.all.firstWhere(
            (c) => c.isoCode == a.countryIso,
            orElse: () => Countries.all.firstWhere(
              (c) => c.dialCode == a.countryCode,
              orElse: () => Countries.defaultCountry,
            ),
          );
  }

  @override
  void dispose() {
    for (final c in [_fullName, _phone, _city, _area, _flatNumber, _postCode, _line1, _line2]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Auto-fill from a picked map location. The location-derived fields are
  /// refreshed to match the new pin (so "change location" updates them), but
  /// only when the geocoder actually returned a value — we never blank out a
  /// field the user may have corrected by hand.
  void _onPlacePicked(ResolvedPlace place) {
    void fill(TextEditingController c, String value) {
      if (value.trim().isNotEmpty) c.text = value;
    }

    setState(() {
      _lat = place.lat;
      _lng = place.lng;
      fill(_city, place.city);
      fill(_area, place.area);
      fill(_postCode, place.postCode);
      fill(_line1, place.line1);
    });
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final address = Address(
      id: widget.address?.id,
      type: _type,
      fullName: _fullName.text.trim(),
      phone: _phone.text.trim(),
      countryCode: _country.dialCode,
      countryIso: _country.isoCode,
      city: _city.text.trim(),
      area: _area.text.trim(),
      flatNumber: _flatNumber.text.trim().isEmpty ? null : _flatNumber.text.trim(),
      postCode: _postCode.text.trim().isEmpty ? null : _postCode.text.trim(),
      line1: _line1.text.trim(),
      line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
      lat: _lat,
      lng: _lng,
      isDefault: _isDefault,
    );
    final bloc = context.read<AddressBloc>();
    bloc.add(widget.isEditing ? AddressUpdated(address) : AddressCreated(address));
  }

  @override
  Widget build(BuildContext context) {
    final titleKey = widget.isEditing ? LocaleKeys.editAddress : LocaleKeys.addNewAddress;
    final saveKey = widget.isEditing ? LocaleKeys.saveChanges : LocaleKeys.saveAddress;

    return BlocListener<AddressBloc, AddressState>(
      listenWhen: (p, c) => p.action != c.action,
      listener: (context, state) {
        if (state.action == AddressAction.success) {
          AppToast.emphasis(context, context.tr(LocaleKeys.changesSavedSuccessfully));
          context.pop();
        } else if (state.action == AddressAction.failure && state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.tr(titleKey))),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: context.edgeAll(20),
              children: [
                AddressMapPicker(
                  initialLat: _lat,
                  initialLng: _lng,
                  initialLabel: widget.address?.label,
                  onPlacePicked: _onPlacePicked,
                ),
                context.gapH(16),
                AddressTypeSelector(
                  selected: _type,
                  onChanged: (t) => setState(() => _type = t),
                ),
                context.gapH(16),
                AppTextField.name(
                  controller: _fullName,
                  hint: context.tr(LocaleKeys.fullName),
                  validator: Validators.name(context),
                ),
                context.gapH(12),
                AppTextField.phone(
                  controller: _phone,
                  hint: context.tr(LocaleKeys.phoneNumber),
                  country: _country,
                  onCountryChanged: (c) => setState(() => _country = c),
                ),
                context.gapH(12),
                AppTextField.text(
                  controller: _city,
                  hint: context.tr(LocaleKeys.city),
                  validator: Validators.required(context),
                ),
                context.gapH(12),
                AppTextField.text(
                  controller: _area,
                  hint: context.tr(LocaleKeys.area),
                  validator: Validators.required(context),
                ),
                context.gapH(12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField.text(
                        controller: _flatNumber,
                        hint: context.tr(LocaleKeys.flatNumber),
                      ),
                    ),
                    context.gapW(12),
                    Expanded(
                      child: AppTextField.text(
                        controller: _postCode,
                        hint: context.tr(LocaleKeys.postCode),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                context.gapH(12),
                AppTextField.text(
                  controller: _line1,
                  hint: context.tr(LocaleKeys.addressLine1),
                  validator: Validators.required(context),
                ),
                context.gapH(12),
                AppTextField.text(
                  controller: _line2,
                  hint: context.tr(LocaleKeys.addressLine2),
                ),
                context.gapH(12),
                _DefaultSwitch(
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v),
                ),
                context.gapH(20),
                BlocBuilder<AddressBloc, AddressState>(
                  buildWhen: (p, c) => p.action != c.action,
                  builder: (context, state) => AppButton.filled(
                    label: context.tr(saveKey),
                    isLoading: state.action == AddressAction.submitting,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Set as a default Address" labelled toggle row.
class _DefaultSwitch extends StatelessWidget {
  const _DefaultSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.tr(LocaleKeys.setAsDefaultAddress),
            style: TextStyle(fontSize: context.sp(14), color: AppColors.textSecondary),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.surface,
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }
}
