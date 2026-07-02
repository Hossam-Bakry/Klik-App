import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/services/location_service.dart';
import '../../../address/presentation/bloc/address_bloc.dart';
import '../../../home/domain/entities/shop_item.dart';
import '../../domain/repositories/shops_repository.dart';

part 'shops_event.dart';
part 'shops_state.dart';

class ShopsBloc extends Bloc<ShopsEvent, ShopsState> {
  ShopsBloc(this._repository, this._addressBloc, this._location)
      : super(const ShopsState()) {
    on<ShopsStarted>(_onStarted);
    on<ShopsRefreshed>(_onRefreshed);
  }

  final ShopsRepository _repository;
  final AddressBloc _addressBloc;
  final LocationService _location;

  Future<void> _onStarted(ShopsStarted event, Emitter<ShopsState> emit) async {
    emit(state.copyWith(status: ShopsStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshed(
    ShopsRefreshed event,
    Emitter<ShopsState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<ShopsState> emit) async {
    final coords = await _resolveCoordinates();
    final result = await _repository.fetchShops(
      lat: coords?.$1,
      lng: coords?.$2,
    );
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: ShopsStatus.success, shops: data));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: ShopsStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  /// A saved address's coordinates when the user has one with a location set,
  /// else the device's current location when it's available (service on,
  /// permission granted) — null (no location params sent) if neither holds.
  Future<(double, double)?> _resolveCoordinates() async {
    for (final address in _addressBloc.state.addresses) {
      if (address.lat != null && address.lng != null) {
        return (address.lat!, address.lng!);
      }
    }

    final result = await _location.resolveCurrentPlace();
    return switch (result) {
      LocationSuccess(:final place) => (place.lat, place.lng),
      LocationFailure() => null,
    };
  }
}
