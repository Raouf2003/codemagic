import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../l10n/l10n.dart';

class GeofenceSettingsScreen extends StatefulWidget {
  const GeofenceSettingsScreen({super.key});

  @override
  State<GeofenceSettingsScreen> createState() => _GeofenceSettingsScreenState();
}

class _GeofenceSettingsScreenState extends State<GeofenceSettingsScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _success;

  final _latController = TextEditingController(text: '35.219445');
  final _lngController = TextEditingController(text: '4.204832');
  double _radius = 50;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await _api.get('/settings/shifts?_t=${DateTime.now().millisecondsSinceEpoch}');
      if (res['companyLocation'] != null) {
        _latController.text = res['companyLocation']['lat'].toString();
        _lngController.text = res['companyLocation']['lng'].toString();
      }
      if (res['allowedRadius'] != null) {
        _radius = (res['allowedRadius'] as num).toDouble();
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);

    if (lat == null || lng == null) {
      setState(() => _error = l10n.invalidCoordinates);
      return;
    }
    if (lat < -90 || lat > 90) {
      setState(() => _error = l10n.latitudeBetween);
      return;
    }
    if (lng < -180 || lng > 180) {
      setState(() => _error = l10n.longitudeBetween);
      return;
    }
    if (_radius < 10 || _radius > 1000) {
      setState(() => _error = l10n.radiusBetween);
      return;
    }

    setState(() { _isSaving = true; _error = null; _success = null; });

    try {
      await _api.put('/settings/geofence', {
        'companyLocation': {'lat': lat, 'lng': lng},
        'allowedRadius': _radius.round(),
      });
      _success = l10n.geofenceUpdated;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.geofenceConfigTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.geofenceDescription,
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.companyLocationSection, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                              child: TextField(
                                controller: _latController,
                                decoration: InputDecoration(
                                  labelText: l10n.latitude,
                                  hintText: l10n.egLatitude,
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _lngController,
                                decoration: InputDecoration(
                                  labelText: l10n.longitude,
                                  hintText: l10n.egLongitude,
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 20),
                          Text('${l10n.allowedRadius}: ${_radius.round()} ${l10n.meters}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(l10n.minMaxRadius,
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                          Slider(
                            value: _radius,
                            min: 10,
                            max: 1000,
                            divisions: 99,
                            label: '${_radius.round()}m',
                            onChanged: (v) => setState(() => _radius = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.location_on),
                      label: Text(_isSaving ? l10n.saving : l10n.saveGeofence),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                  if (_success != null) ...[
                    const SizedBox(height: 16),
                    Row(children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                      const SizedBox(width: 6),
                      Expanded(child: Text(_success!, style: TextStyle(color: Colors.green.shade600, fontSize: 13))),
                    ]),
                  ],
                ],
              ),
            ),
    );
  }
}
