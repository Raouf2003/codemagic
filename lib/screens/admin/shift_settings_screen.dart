import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../services/api_service.dart';

class ShiftSettingsScreen extends StatefulWidget {
  const ShiftSettingsScreen({super.key});

  @override
  State<ShiftSettingsScreen> createState() => _ShiftSettingsScreenState();
}

class _ShiftSettingsScreenState extends State<ShiftSettingsScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _success;

  TimeOfDay _morningStart = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _morningEnd = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _eveningStart = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _eveningEnd = const TimeOfDay(hour: 16, minute: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await _api.get('/settings/shifts?_t=${DateTime.now().millisecondsSinceEpoch}');
      _morningStart = _parseTime(res['morningStart'] ?? '08:00');
      _morningEnd = _parseTime(res['morningEnd'] ?? '12:00');
      _eveningStart = _parseTime(res['eveningStart'] ?? '13:00');
      _eveningEnd = _parseTime(res['eveningEnd'] ?? '16:00');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  TimeOfDay _parseTime(String str) {
    final parts = str.split(':');
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0);
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(TimeOfDay current, ValueChanged<TimeOfDay> onPicked) async {
    final t = await showTimePicker(
      context: context,
      initialTime: current,
      initialEntryMode: TimePickerEntryMode.input,
      helpText: AppLocalizations.of(context).selectTime24h,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (t != null) onPicked(t);
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() { _isSaving = true; _error = null; _success = null; });

    final morningStartMin = _toMinutes(_morningStart);
    final morningEndMin = _toMinutes(_morningEnd);
    var eveningStartMin = _toMinutes(_eveningStart);
    var eveningEndMin = _toMinutes(_eveningEnd);

    // Validate morning shift (same day)
    if (morningStartMin >= morningEndMin) {
      setState(() { _isSaving = false; _error = l10n.morningStartBeforeEnd; });
      return;
    }

    // If evening end is earlier than start, it crosses midnight (next day)
    if (eveningEndMin < eveningStartMin) {
      eveningEndMin += 1440;
    }

    // Validate evening shift end > start
    if (eveningStartMin >= eveningEndMin) {
      setState(() { _isSaving = false; _error = l10n.eveningStartBeforeEnd; });
      return;
    }

    // Validate no overlap: evening start must be after morning end
    // If evening start is before morning end (e.g., 00:00), treat it as next day
    if (eveningStartMin < morningStartMin) {
      eveningStartMin += 1440;
    }
    if (morningEndMin >= eveningStartMin) {
      setState(() { _isSaving = false; _error = l10n.noOverlap; });
      return;
    }

    final oldMorningStart = _morningStart;
    final oldMorningEnd = _morningEnd;
    final oldEveningStart = _eveningStart;
    final oldEveningEnd = _eveningEnd;

    try {
      final res = await _api.put('/settings/shifts', {
        'morningStart': _formatTime(_morningStart),
        'morningEnd': _formatTime(_morningEnd),
        'eveningStart': _formatTime(_eveningStart),
        'eveningEnd': _formatTime(_eveningEnd),
      });
      _morningStart = _parseTime(res['morningStart'] ?? _formatTime(_morningStart));
      _morningEnd = _parseTime(res['morningEnd'] ?? _formatTime(_morningEnd));
      _eveningStart = _parseTime(res['eveningStart'] ?? _formatTime(_eveningStart));
      _eveningEnd = _parseTime(res['eveningEnd'] ?? _formatTime(_eveningEnd));
      _success = l10n.shiftUpdated;
    } catch (e) {
      _morningStart = oldMorningStart;
      _morningEnd = oldMorningEnd;
      _eveningStart = oldEveningStart;
      _eveningEnd = oldEveningEnd;
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shiftConfig)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.setShiftTimes,
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
                  const SizedBox(height: 20),
                  _buildTimeField(l10n.morningStart, Icons.wb_sunny, Colors.orange, _morningStart, (v) => _morningStart = v),
                  const SizedBox(height: 10),
                  _buildTimeField(l10n.morningEnd, Icons.wb_sunny, Colors.orange, _morningEnd, (v) => _morningEnd = v),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  _buildTimeField(l10n.eveningStart, Icons.nights_stay, Colors.indigo, _eveningStart, (v) => _eveningStart = v),
                  const SizedBox(height: 10),
                  _buildTimeField(l10n.eveningEnd, Icons.nights_stay, Colors.indigo, _eveningEnd, (v) => _eveningEnd = v),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.schedule),
                      label: Text(_isSaving ? l10n.saving : l10n.saveShiftTimes),
                    ),
                  ),
                  if (_error != null && _success == null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                      ]),
                    ),
                  ],
                  if (_success != null && _error == null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_success!, style: TextStyle(color: Colors.green.shade700, fontSize: 13))),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildTimeField(String label, IconData icon, Color color, TimeOfDay value, ValueChanged<TimeOfDay> onChanged) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color, size: 20)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: FilledButton.tonal(
          onPressed: () => _pickTime(value, onChanged),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          child: Text(
            _formatTime(value),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace',
              color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
