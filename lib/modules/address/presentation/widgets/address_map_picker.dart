import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/location_picker_page.dart';

/// Map header for the add/edit address screen.
///
/// Shows a Google Map with a single marker. Tapping the map, or the "use
/// current location" row beneath it, resolves a [ResolvedPlace] (reverse
/// geocoded) and hands it back via [onPlacePicked] so the form can auto-fill.
class AddressMapPicker extends StatefulWidget {
  const AddressMapPicker({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialLabel,
    required this.onPlacePicked,
  });

  final double? initialLat;
  final double? initialLng;
  final String? initialLabel;
  final ValueChanged<ResolvedPlace> onPlacePicked;

  @override
  State<AddressMapPicker> createState() => _AddressMapPickerState();
}

class _AddressMapPickerState extends State<AddressMapPicker> {
  final LocationService _location = sl<LocationService>();

  // Fallback centre (Kuwait City) until we have a real position.
  static const LatLng _fallback = LatLng(29.3759, 47.9774);

  GoogleMapController? _controller;
  LatLng? _marker;
  String? _label;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _label = widget.initialLabel;
    if (widget.initialLat != null && widget.initialLng != null) {
      _marker = LatLng(widget.initialLat!, widget.initialLng!);
    } else {
      // No starting point (add flow) — try the current location once.
      WidgetsBinding.instance.addPostFrameCallback((_) => _useCurrentLocation());
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  LatLng get _center => _marker ?? _fallback;

  Future<void> _useCurrentLocation() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await _location.resolveCurrentPlace();
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case LocationSuccess(:final place):
        _applyPlace(place);
      case LocationFailure(:final error):
        _showError(error);
    }
  }

  /// Opens the full-screen picker so the user can browse the map and choose any
  /// location; the result is applied (and auto-fills the form) on confirm.
  Future<void> _openFullScreenPicker() async {
    final place = await LocationPickerPage.open(
      context,
      initialLat: _marker?.latitude,
      initialLng: _marker?.longitude,
    );
    if (place != null && mounted) _applyPlace(place);
  }

  Future<void> _onMapTapped(LatLng pos) async {
    setState(() {
      _marker = pos;
      _busy = true;
    });
    final place = await _location.reverseGeocode(pos.latitude, pos.longitude);
    if (!mounted) return;
    setState(() => _busy = false);
    _applyPlace(place);
  }

  void _applyPlace(ResolvedPlace place) {
    final target = LatLng(place.lat, place.lng);
    setState(() {
      _marker = target;
      _label = place.label;
    });
    _controller?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
    widget.onPlacePicked(place);
  }

  void _showError(LocationError error) {
    final key = switch (error) {
      LocationError.serviceDisabled => LocaleKeys.locationServiceDisabled,
      LocationError.permissionDeniedForever => LocaleKeys.locationPermissionDeniedForever,
      _ => LocaleKeys.locationPermissionDenied,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.tr(key))));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(context.r(14)),
          child: SizedBox(
            height: context.r(150),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _center, zoom: 14),
                  onMapCreated: (c) {
                    _controller = c;
                    if (_marker != null) {
                      c.animateCamera(CameraUpdate.newLatLngZoom(_marker!, 16));
                    }
                  },
                  onTap: _onMapTapped,
                  markers: {
                    if (_marker != null)
                      Marker(markerId: const MarkerId('picked'), position: _marker!),
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  liteModeEnabled: false,
                ),
                if (_busy)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x22000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ),
        context.gapH(12),
        _LocationSummary(label: _label, onChange: _openFullScreenPicker),
      ],
    );
  }
}

/// The bordered "pin • address • change" row under the map.
class _LocationSummary extends StatelessWidget {
  const _LocationSummary({required this.label, required this.onChange});

  final String? label;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.edgeSymmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: const Color(0xFFE6E0D4)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.primary, size: context.r(20)),
          context.gapW(8),
          Expanded(
            child: Text(
              label?.isNotEmpty == true
                  ? label!
                  : context.tr(LocaleKeys.useCurrentLocation),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: context.sp(13),
                color: AppColors.textPrimary,
              ),
            ),
          ),
          context.gapW(8),
          GestureDetector(
            onTap: onChange,
            child: Text(
              context.tr(LocaleKeys.change),
              style: TextStyle(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
