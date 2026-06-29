part of 'address_bloc.dart';

/// List-load lifecycle.
enum AddressStatus { initial, loading, success, failure }

/// Lifecycle of a create/update/delete mutation — drives the save button
/// spinner and the "pop on success" listener on the add/edit page.
enum AddressAction { idle, submitting, success, failure }

class AddressState extends Equatable {
  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.selected,
    this.currentLabel,
    this.locating = false,
    this.action = AddressAction.idle,
    this.errorMessage,
  });

  final AddressStatus status;
  final List<Address> addresses;

  /// The chosen delivery address, if any.
  final Address? selected;

  /// GPS-derived label shown in "Deliver to" when the user has no saved
  /// addresses (kept in memory only).
  final String? currentLabel;

  /// True while resolving the current location.
  final bool locating;

  final AddressAction action;
  final String? errorMessage;

  bool get isLoading =>
      status == AddressStatus.initial || status == AddressStatus.loading;

  bool get hasAddresses => addresses.isNotEmpty;

  /// What the "Deliver to" header shows: the selected address, else the GPS
  /// label, else null (caller falls back to a default string).
  String? get deliveryLabel => selected?.label ?? currentLabel;

  AddressState copyWith({
    AddressStatus? status,
    List<Address>? addresses,
    Address? selected,
    bool clearSelected = false,
    String? currentLabel,
    bool? locating,
    AddressAction? action,
    String? errorMessage,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      selected: clearSelected ? null : (selected ?? this.selected),
      currentLabel: currentLabel ?? this.currentLabel,
      locating: locating ?? this.locating,
      action: action ?? this.action,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        addresses,
        selected,
        currentLabel,
        locating,
        action,
        errorMessage,
      ];
}
