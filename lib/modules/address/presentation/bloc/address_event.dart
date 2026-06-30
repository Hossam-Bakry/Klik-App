part of 'address_bloc.dart';

sealed class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load: fetch saved addresses, restore the selected one, or fall back
/// to the current-location label when the user has none.
class AddressStarted extends AddressEvent {
  const AddressStarted();
}

/// Re-fetch the list (e.g. after returning to the screen).
class AddressRefreshed extends AddressEvent {
  const AddressRefreshed();
}

/// User picked an address from the bottom sheet.
class AddressSelected extends AddressEvent {
  const AddressSelected(this.address);
  final Address address;
}

/// Persist a brand-new address, then reload and select it.
class AddressCreated extends AddressEvent {
  const AddressCreated(this.address);
  final Address address;
}

/// Persist edits to an existing address.
class AddressUpdated extends AddressEvent {
  const AddressUpdated(this.address);
  final Address address;
}

/// Remove an address.
class AddressDeleted extends AddressEvent {
  const AddressDeleted(this.id);
  final int id;
}

/// Drop all saved addresses and the selection (e.g. on logout), then fall back
/// to the current-location label so the guest header still shows something.
class AddressCleared extends AddressEvent {
  const AddressCleared();
}

/// Resolve the device's current location into a "Deliver to" label (used when
/// the user has no saved addresses).
class CurrentLocationRequested extends AddressEvent {
  const CurrentLocationRequested();
}
