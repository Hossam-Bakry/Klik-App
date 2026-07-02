import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';

/// Full-screen map for browsing and picking any location.
///
/// The map moves under a fixed centre pin (Google/Uber style). When the camera
/// settles, the centre point is reverse-geocoded and shown in the bottom card;
/// "Confirm location" pops with the [ResolvedPlace] so the caller can auto-fill.
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key, this.initialLat, this.initialLng});

  final double? initialLat;
  final double? initialLng;

  /// Pushes the picker and resolves to the chosen place, or null if dismissed.
  static Future<ResolvedPlace?> open(
    BuildContext context, {
    double? initialLat,
    double? initialLng,
  }) {
    return Navigator.of(context).push<ResolvedPlace>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialLat: initialLat,
          initialLng: initialLng,
        ),
      ),
    );
  }

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final LocationService _location = sl<LocationService>();

  // Fallback centre (Kuwait City) until we have a real position.
  static const LatLng _fallback = LatLng(29.3759, 47.9774);

  GoogleMapController? _controller;
  late LatLng _target;
  ResolvedPlace? _place;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _target = LatLng(widget.initialLat!, widget.initialLng!);
      _resolve(_target);
    } else {
      _target = _fallback;
      // No starting point — drop the user on their current location once.
      WidgetsBinding.instance.addPostFrameCallback((_) => _useCurrentLocation());
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Reverse-geocode the given point and show it in the bottom card.
  Future<void> _resolve(LatLng pos) async {
    setState(() => _busy = true);
    final place = await _location.reverseGeocode(pos.latitude, pos.longitude);
    if (!mounted) return;
    setState(() {
      _place = place;
      _busy = false;
    });
  }

  Future<void> _useCurrentLocation() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await _location.resolveCurrentPlace();
    if (!mounted) return;
    switch (result) {
      case LocationSuccess(:final place):
        final target = LatLng(place.lat, place.lng);
        setState(() {
          _target = target;
          _place = place;
          _busy = false;
        });
        _controller?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
      case LocationFailure(:final error):
        setState(() => _busy = false);
        _showError(error);
    }
  }

  void _confirm() {
    // Always hand back the centre coordinates; the resolved address parts are
    // best-effort and may be empty if geocoding failed.
    final place = _place ?? ResolvedPlace(lat: _target.latitude, lng: _target.longitude);
    Navigator.of(context).pop(place);
  }

  void _showError(LocationError error) {
    final key = switch (error) {
      LocationError.serviceDisabled => LocaleKeys.locationServiceDisabled,
      LocationError.permissionDeniedForever => LocaleKeys.locationPermissionDeniedForever,
      _ => LocaleKeys.locationPermissionDenied,
    };
    AppToast.warning(context, context.tr(key));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(LocaleKeys.selectLocation))),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _target, zoom: 16),
            onMapCreated: (c) => _controller = c,
            onCameraMove: (pos) => _target = pos.target,
            onCameraIdle: () => _resolve(_target),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          // Fixed centre pin — nudged up so its tip sits on the map centre.
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: context.r(36)),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: context.r(44),
                ),
              ),
            ),
          ),
          if (_busy)
            Positioned(
              top: context.r(16),
              right: context.r(16),
              left: context.r(16),
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            right: context.r(16),
            bottom: context.r(180),
            child: FloatingActionButton.small(
              heroTag: 'pickerMyLocation',
              backgroundColor: AppColors.surface,
              onPressed: _useCurrentLocation,
              child: Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _PickedCard(
              label: _place?.label,
              onConfirm: _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet-like card showing the picked address and the confirm CTA.
class _PickedCard extends StatelessWidget {
  const _PickedCard({required this.label, required this.onConfirm});

  final String? label;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: context.edgeAll(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primary, size: context.r(22)),
                  context.gapW(8),
                  Expanded(
                    child: Text(
                      label?.isNotEmpty == true
                          ? label!
                          : context.tr(LocaleKeys.moveMapToSelect),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.sp(14),
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              context.gapH(16),
              AppButton.filled(
                label: context.tr(LocaleKeys.confirmLocation),
                onPressed: onConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
