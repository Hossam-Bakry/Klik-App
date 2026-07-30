import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../gen/assets.gen.dart';
import '../../domain/entities/address.dart';
import '../bloc/address_bloc.dart';
import '../widgets/delete_address_dialog.dart';

/// "Manage Address" screen reached from Profile. Lists the saved addresses with
/// edit (tap) and delete (swipe) actions, or an empty-state illustration when
/// there are none. Shares the singleton [AddressBloc], so changes here are
/// reflected in the home header and the chooser sheet.
class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  @override
  void initState() {
    super.initState();
    // Refresh on entry so edits/deletes made elsewhere are in sync.
    context.read<AddressBloc>().add(const AddressRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        centerTitle: false,
        title: Text(context.tr(LocaleKeys.addressTitle)),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.addressAdd),
            icon: Icon(Icons.add, size: context.r(20), color: AppColors.primary),
            label: Text(
              context.tr(LocaleKeys.add),
              style: context.bodyLarge?.copyWith(color: AppColors.primary),
            ),
          ),
          context.gapW(8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocConsumer<AddressBloc, AddressState>(
          // Surface a failed delete (the only mutation on this screen that
          // doesn't go through the add/edit page's own listener).
          listenWhen: (p, c) =>
              c.errorMessage != null && p.errorMessage != c.errorMessage,
          listener: (context, state) {
            AppToast.error(context, state.errorMessage!);
          },
          builder: (context, state) {
            if (state.isLoading && !state.hasAddresses) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!state.hasAddresses) return const _EmptyAddresses();

            return ListView.separated(
              padding: context.edge(left: 20, right: 20, top: 8, bottom: 24),
              itemCount: state.addresses.length,
              separatorBuilder: (_, _) =>
                  Divider(color: AppColors.border, height: context.r(24)),
              itemBuilder: (context, i) {
                final address = state.addresses[i];
                return _AddressRow(
                  address: address,
                  onTap: () =>
                      context.push(AppRoutes.addressEdit, extra: address),
                  onDelete: () => _confirmDelete(context, address),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Address address) async {
    final confirmed = await showDeleteAddressDialog(context);
    if (confirmed && address.id != null && context.mounted) {
      context.read<AddressBloc>().add(AddressDeleted(address.id!));
    }
  }
}

/// One address in the list: a pin, the address name + detail, and a trailing
/// chevron. Swiping reveals a delete action that asks for confirmation.
class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.address,
    required this.onTap,
    required this.onDelete,
  });

  final Address address;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = address.line1.trim().isNotEmpty ? address.line1 : address.label;
    final detail = [address.line2, address.area, address.city]
        .where((p) => p != null && p.trim().isNotEmpty)
        .join(', ');

    return Dismissible(
      key: ValueKey(address.id ?? address),
      direction: DismissDirection.endToStart,
      // Confirm via the dialog; deletion is driven by the bloc reload, so we
      // never let Dismissible remove the row itself (return false).
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: _DeleteBackground(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: context.edgeSymmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Assets.icons.locationIcn.svg(
                width: context.r(22),
                color: AppColors.primary,
              ),
              context.gapW(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (detail.isNotEmpty) ...[
                      context.gapH(4),
                      Text(
                        detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              context.gapW(8),
              Icon(
                Icons.chevron_right_rounded,
                size: context.r(24),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bronze trash affordance revealed behind a row as it's swiped left.
class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: context.edgeSymmetric(vertical: 6),
        child: Container(
          padding: context.edgeAll(8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(context.r(8)),
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: AppColors.primary,
            size: context.r(22),
          ),
        ),
      ),
    );
  }
}

/// Empty-state shown when no addresses are saved.
class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses();

  @override
  Widget build(BuildContext context) {
    return EmptyView(
      image: Assets.images.emptyAddressImg.image(width: context.wf(0.6)),
      message: context.tr(LocaleKeys.noAddressesAdded),
    );
  }
}
