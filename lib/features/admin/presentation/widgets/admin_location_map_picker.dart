import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:menu_2026/l10n/app_localizations.dart";

/// Location is chosen by dropping a pin on a full-screen map — not typed as lat/lng.
class AdminLocationMapPicker extends FormField<LatLng> {
  AdminLocationMapPicker({
    super.key,
    required TextEditingController latController,
    required TextEditingController lngController,
    required AppLocalizations l10n,
    bool locationRequired = false,
    double previewHeight = 160,
  }) : super(
          initialValue: parseLatLng(latController.text, lngController.text),
          validator: (LatLng? value) {
            if (!locationRequired) return null;
            if (value == null) return l10n.adminLocationRequired;
            return null;
          },
          builder: (FormFieldState<LatLng> field) {
            return _AdminLocationMapPickerBody(
              field: field,
              latController: latController,
              lngController: lngController,
              l10n: l10n,
              previewHeight: previewHeight,
            );
          },
        );

  static const LatLng defaultCenter = LatLng(31.9539, 35.9106); // Amman

  static LatLng? parseLatLng(String latRaw, String lngRaw) {
    final double? lat = double.tryParse(latRaw.trim());
    final double? lng = double.tryParse(lngRaw.trim());
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    return LatLng(lat, lng);
  }
}

class _AdminLocationMapPickerBody extends StatelessWidget {
  const _AdminLocationMapPickerBody({
    required this.field,
    required this.latController,
    required this.lngController,
    required this.l10n,
    required this.previewHeight,
  });

  final FormFieldState<LatLng> field;
  final TextEditingController latController;
  final TextEditingController lngController;
  final AppLocalizations l10n;
  final double previewHeight;

  Future<void> _openPicker(BuildContext context) async {
    final LatLng? picked = await Navigator.of(context, rootNavigator: true).push<LatLng>(
      MaterialPageRoute<LatLng>(
        fullscreenDialog: true,
        builder: (BuildContext ctx) => AdminLocationMapPickerPage(
          initial: field.value ??
              AdminLocationMapPicker.parseLatLng(
                latController.text,
                lngController.text,
              ),
        ),
      ),
    );
    if (picked == null) return;
    latController.text = picked.latitude.toStringAsFixed(6);
    lngController.text = picked.longitude.toStringAsFixed(6);
    field.didChange(picked);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final LatLng? pin = field.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Material(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openPicker(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: previewHeight,
                  child: ColoredBox(
                    color: theme.colorScheme.surfaceContainerHigh,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            pin == null
                                ? Icons.add_location_alt_outlined
                                : Icons.location_on,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pin == null
                                ? l10n.adminPickLocationOnMap
                                : l10n.adminChangeLocationOnMap,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              pin == null
                                  ? l10n.adminMapPickerHint
                                  : l10n.adminLocationPicked(
                                      pin.latitude.toStringAsFixed(5),
                                      pin.longitude.toStringAsFixed(5),
                                    ),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (field.hasError) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            field.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class AdminLocationMapPickerPage extends StatefulWidget {
  const AdminLocationMapPickerPage({super.key, this.initial});

  final LatLng? initial;

  @override
  State<AdminLocationMapPickerPage> createState() =>
      _AdminLocationMapPickerPageState();
}

class _AdminLocationMapPickerPageState extends State<AdminLocationMapPickerPage> {
  GoogleMapController? _map;
  late LatLng _cameraTarget;
  LatLng? _pin;

  @override
  void initState() {
    super.initState();
    _pin = widget.initial;
    _cameraTarget = widget.initial ?? AdminLocationMapPicker.defaultCenter;
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  void _setPin(LatLng pos) {
    setState(() {
      _pin = pos;
      _cameraTarget = pos;
    });
    _map?.animateCamera(CameraUpdate.newLatLng(pos));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminPickLocationOnMap),
        actions: <Widget>[
          TextButton(
            onPressed: _pin == null
                ? null
                : () => Navigator.of(context).pop(_pin),
            child: Text(l10n.adminConfirmLocation),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _cameraTarget,
              zoom: widget.initial == null ? 12 : 16,
            ),
            onMapCreated: (GoogleMapController controller) {
              _map = controller;
            },
            onTap: _setPin,
            markers: _pin == null
                ? <Marker>{}
                : <Marker>{
                    Marker(
                      markerId: const MarkerId("branch_pin"),
                      position: _pin!,
                      draggable: true,
                      onDragEnd: _setPin,
                    ),
                  },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 12,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text(
                  l10n.adminMapPickerHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
