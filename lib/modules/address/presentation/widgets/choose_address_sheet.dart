import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/address.dart';
import '../bloc/address_bloc.dart';

/// Opens the "Choose Address Location" bottom sheet. If the user has no saved
/// addresses yet, it skips the sheet and goes straight to the Add screen
/// (requirement #2).
Future<void> showChooseAddressSheet(BuildContext context) {
  final bloc = context.read<AddressBloc>();
  if (!bloc.state.hasAddresses) {
    context.push(AppRoutes.addressAdd);
    return Future.value();
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) =>
        BlocProvider.value(value: bloc, child: const _ChooseAddressSheet()),
  );
}

class _ChooseAddressSheet extends StatefulWidget {
  const _ChooseAddressSheet();

  @override
  State<_ChooseAddressSheet> createState() => _ChooseAddressSheetState();
}

class _ChooseAddressSheetState extends State<_ChooseAddressSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Case-insensitive match across the parts a user would type to find an
  /// address (label, recipient, and the address lines).
  bool _matches(Address a, String query) {
    final haystack = [
      a.label,
      a.fullName,
      a.city,
      a.area,
      a.line1,
      a.line2,
      a.postCode,
    ].whereType<String>().join(' ').toLowerCase();
    return haystack.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.edge(left: 20, right: 20, top: 16, bottom: 16),
      child: SafeArea(
        child: BlocBuilder<AddressBloc, AddressState>(
          builder: (context, state) {
            final query = _query.trim().toLowerCase();
            final addresses = query.isEmpty
                ? state.addresses
                : state.addresses.where((a) => _matches(a, query)).toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: context.r(40),
                    height: context.r(4),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                context.gapH(16),
                Text(
                  context.tr(LocaleKeys.chooseAddressLocation),
                  style: TextStyle(
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                context.gapH(16),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: AppTextField.search(
                    controller: _searchController,
                    hint: context.tr(LocaleKeys.searchAnAddress),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                context.gapH(20),
                Text(
                  context.tr(LocaleKeys.savedAddresses),
                  style: TextStyle(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                context.gapH(8),
                if (addresses.isEmpty)
                  Padding(
                    padding: context.edgeSymmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        context.tr(LocaleKeys.noAddressesFound),
                        style: TextStyle(
                          fontSize: context.sp(13),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: addresses.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final address = addresses[i];
                        return _AddressTile(
                          address: address,
                          isSelected: state.selected?.id == address.id,
                          onTap: () {
                            context.read<AddressBloc>().add(
                              AddressSelected(address),
                            );
                            Navigator.of(context).pop();
                          },
                          onEdit: () {
                            Navigator.of(context).pop();
                            context.push(AppRoutes.addressEdit, extra: address);
                          },
                        );
                      },
                    ),
                  ),
                context.gapH(8),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.addressAdd);
                    },
                    icon: Icon(
                      Icons.add,
                      color: AppColors.primary,
                      size: context.r(20),
                    ),
                    label: Text(
                      context.tr(LocaleKeys.addNewAddress),
                      style: TextStyle(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
  });

  final Address address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final detail = [
      address.line1,
      address.line2,
      address.area,
    ].where((p) => p != null && p.trim().isNotEmpty).join('، ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: context.edgeSymmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: context.r(22),
            ),
            context.gapW(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: TextStyle(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (detail.isNotEmpty) ...[
                    context.gapH(2),
                    Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.sp(12),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            context.gapW(8),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: context.r(22),
              )
            else
              GestureDetector(
                onTap: onEdit,
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: context.r(22),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
