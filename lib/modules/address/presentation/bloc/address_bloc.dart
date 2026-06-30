import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';

part 'address_event.dart';
part 'address_state.dart';

/// Owns the user's saved addresses and the currently selected delivery address.
///
/// Registered as a singleton (selection must persist across tabs and the
/// add/edit routes). The selected id is mirrored to [SharedPreferences] so the
/// choice survives an app restart. When the user has no saved addresses, the
/// bloc resolves the current GPS location into an in-memory [currentLabel].
class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc(this._repository, this._location, this._prefs)
      : super(const AddressState()) {
    on<AddressStarted>(_onStarted);
    on<AddressRefreshed>(_onRefreshed);
    on<AddressSelected>(_onSelected);
    on<AddressCreated>(_onCreated);
    on<AddressUpdated>(_onUpdated);
    on<AddressDeleted>(_onDeleted);
    on<AddressCleared>(_onCleared);
    on<CurrentLocationRequested>(_onCurrentLocation);
  }

  final AddressRepository _repository;
  final LocationService _location;
  final SharedPreferences _prefs;

  static const _selectedKey = 'selected_address_id';

  Future<void> _onStarted(AddressStarted event, Emitter<AddressState> emit) async {
    emit(state.copyWith(status: AddressStatus.loading));
    await _loadAndRestore(emit);
  }

  Future<void> _onRefreshed(
      AddressRefreshed event, Emitter<AddressState> emit) async {
    await _loadAndRestore(emit);
  }

  /// Fetches the list and restores the selection: the persisted id if still
  /// present, else the default address, else the first. With no addresses, it
  /// falls back to the current-location label.
  Future<void> _loadAndRestore(Emitter<AddressState> emit) async {
    final result = await _repository.getAddresses();
    switch (result) {
      case ApiSuccess(:final data):
        if (data.isEmpty) {
          emit(state.copyWith(
            status: AddressStatus.success,
            addresses: const [],
            clearSelected: true,
          ));
          add(const CurrentLocationRequested());
          return;
        }
        emit(state.copyWith(
          status: AddressStatus.success,
          addresses: data,
          selected: _restoreSelection(data),
        ));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: AddressStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  Address _restoreSelection(List<Address> addresses) {
    final savedId = _prefs.getInt(_selectedKey);
    return addresses.firstWhere(
      (a) => a.id == savedId,
      orElse: () => addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      ),
    );
  }

  Future<void> _onSelected(
      AddressSelected event, Emitter<AddressState> emit) async {
    await _persistSelection(event.address.id);
    emit(state.copyWith(selected: event.address));
  }

  Future<void> _onCreated(
      AddressCreated event, Emitter<AddressState> emit) async {
    emit(state.copyWith(action: AddressAction.submitting));
    final result = await _repository.createAddress(event.address);
    await _afterMutation(result, emit, selectId: (saved) => saved.id);
  }

  Future<void> _onUpdated(
      AddressUpdated event, Emitter<AddressState> emit) async {
    emit(state.copyWith(action: AddressAction.submitting));
    final result = await _repository.updateAddress(event.address);
    await _afterMutation(result, emit, selectId: (_) => event.address.id);
  }

  /// Shared tail for create/update: on success reload the list, re-select the
  /// relevant address, and flag the action so the page can pop.
  Future<void> _afterMutation(
    ApiResult<Address> result,
    Emitter<AddressState> emit, {
    required int? Function(Address saved) selectId,
  }) async {
    switch (result) {
      case ApiSuccess(:final data):
        final targetId = selectId(data);
        final listResult = await _repository.getAddresses();
        final list = listResult.dataOrNull ?? state.addresses;
        final selected = list.firstWhere(
          (a) => a.id == targetId,
          orElse: () => list.isNotEmpty ? list.first : data,
        );
        await _persistSelection(selected.id);
        emit(state.copyWith(
          status: AddressStatus.success,
          addresses: list,
          selected: selected,
          action: AddressAction.success,
        ));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          action: AddressAction.failure,
          errorMessage: failure.message,
        ));
    }
    // Reset to idle so a later submit can transition again.
    emit(state.copyWith(action: AddressAction.idle));
  }

  Future<void> _onDeleted(
      AddressDeleted event, Emitter<AddressState> emit) async {
    final result = await _repository.deleteAddress(event.id);
    if (result is ApiFailure) {
      emit(state.copyWith(
        errorMessage: (result as ApiFailure).failure.message,
      ));
      return;
    }
    final wasSelected = state.selected?.id == event.id;
    if (wasSelected) await _persistSelection(null);
    await _loadAndRestore(emit);
  }

  Future<void> _onCleared(
      AddressCleared event, Emitter<AddressState> emit) async {
    await _persistSelection(null);
    emit(state.copyWith(
      status: AddressStatus.success,
      addresses: const [],
      clearSelected: true,
    ));
    add(const CurrentLocationRequested());
  }

  Future<void> _onCurrentLocation(
      CurrentLocationRequested event, Emitter<AddressState> emit) async {
    emit(state.copyWith(locating: true));
    final result = await _location.resolveCurrentPlace();
    switch (result) {
      case LocationSuccess(:final place):
        emit(state.copyWith(locating: false, currentLabel: place.label));
      case LocationFailure():
        // Silent on the header — keep whatever label we had. The add screen
        // surfaces location errors where the user explicitly asked for them.
        emit(state.copyWith(locating: false));
    }
  }

  Future<void> _persistSelection(int? id) async {
    if (id == null) {
      await _prefs.remove(_selectedKey);
    } else {
      await _prefs.setInt(_selectedKey, id);
    }
  }
}
