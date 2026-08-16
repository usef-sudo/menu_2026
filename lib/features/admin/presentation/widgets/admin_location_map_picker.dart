import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";

/// Tap the map to set branch coordinates. Controllers are updated on tap.
class AdminLocationMapPicker extends StatefulWidget {
  const AdminLocationMapPicker({
    super.key,
    required this.latController,
    required this.lngController,
    this.height = 220,
  });

  final TextEditingController latController;
  final TextEditingController lngController;
  final double height;

  static const LatLng defaultCenter = LatLng(31.9539, 35.9106); // Amman

  @override
  State<AdminLocationMapPicker> createState() => _AdminLocationMapPickerState();
}

class _AdminLocationMapPickerState extends State<AdminLocationMapPicker> {
  LatLng? _pin;

  @override
  void initState() {
    super.initState();
    _pin = _parseControllers();
    widget.latController.addListener(_syncFromControllers);
    widget.lngController.addListener(_syncFromControllers);
  }

  @override
  void dispose() {
    widget.latController.removeListener(_syncFromControllers);
    widget.lngController.removeListener(_syncFromControllers);
    super.dispose();
  }

  LatLng? _parseControllers() {
    final double? lat = double.tryParse(widget.latController.text.trim());
    final double? lng = double.tryParse(widget.lngController.text.trim());
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    return LatLng(lat, lng);
  }

  void _syncFromControllers() {
    final LatLng? next = _parseControllers();
    if (next == null) return;
    if (_pin != null &&
        (_pin!.latitude - next.latitude).abs() < 1e-7 &&
        (_pin!.longitude - next.longitude).abs() < 1e-7) {
      return;
    }
    setState(() => _pin = next);
  }

  void _onTap(LatLng pos) {
    setState(() => _pin = pos);
    widget.latController.text = pos.latitude.toStringAsFixed(6);
    widget.lngController.text = pos.longitude.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final LatLng center = _pin ?? AdminLocationMapPicker.defaultCenter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          "Tap the map to set location",
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: center, zoom: 13),
              markers: _pin == null
                  ? <Marker>{}
                  : <Marker>{
                      Marker(
                        markerId: const MarkerId("branch_pin"),
                        position: _pin!,
                      ),
                    },
              onTap: _onTap,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
            ),
          ),
        ),
      ],
    );
  }
}
