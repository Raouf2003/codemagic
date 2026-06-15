import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class ManualAttendancePage extends StatefulWidget {
  const ManualAttendancePage({super.key});

  @override
  State<ManualAttendancePage> createState() => _ManualAttendancePageState();
}

class _ManualAttendancePageState extends State<ManualAttendancePage> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;
  bool _loadError = false;

  String? _selectedId;
  DateTime _selectedDate = DateTime.now();
  String _period = 'morning';
  TimeOfDay _checkInTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? _checkOutTime;
  bool _hasCheckOut = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      final response = await _api.get('/employees');
      final list = ((response['employees'] as List?) ?? [])
          .where((e) => e['role'] != 'admin')
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (mounted) setState(() { _employees = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _loadError = true; });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedId == null) return;

    setState(() => _submitting = true);

    final checkInDt = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _checkInTime.hour, _checkInTime.minute,
    );
    DateTime? checkOutDt;
    if (_hasCheckOut && _checkOutTime != null) {
      checkOutDt = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _checkOutTime!.hour, _checkOutTime!.minute,
      );
      if (checkOutDt.isBefore(checkInDt) || checkOutDt.isAtSameMomentAs(checkInDt)) {
        setState(() => _submitting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).checkOutAfterCheckIn)),
          );
        }
        return;
      }
    }

    try {
      await _api.post('/admin/attendance', {
        'employeeId': _selectedId,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'period': _period,
        'checkInTime': checkInDt.toUtc().toIso8601String(),
        'checkOutTime': checkOutDt?.toUtc().toIso8601String(),
      }, requiresAuth: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const GapW(10),
              const Text('Success!'),
            ]),
            backgroundColor: AppColors.emerald,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(l10n.manualAttendance),
        actions: [
          TextButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_rounded, size: 18),
            label: Text(_submitting ? l10n.saving : l10n.save),
          ),
        ],
      ),
      body: _loading ? _buildSkeleton() : _loadError ? _buildError() : _buildForm(l10n),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: AppSpacing.page,
      children: List.generate(4, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Card(
          child: Padding(
            padding: AppSpacing.allMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 12, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
                const GapH(16),
                Container(width: double.infinity, height: 44, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(8))),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: AppColors.red.withValues(alpha: 0.6)),
            const GapH(16),
            Text('Something went wrong', style: AppTypography.body, textAlign: TextAlign.center),
            const GapH(20),
            FilledButton.tonalIcon(
              onPressed: () { setState(() { _loading = true; _loadError = false; }); _loadEmployees(); },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SectionCard(
            title: l10n.employee,
            icon: Icons.person_rounded,
            child: _employees.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('No non-admin employees found', style: AppTypography.bodySm.copyWith(color: AppColors.textMuted)),
                  )
                : DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: l10n.employee,
                      prefixIcon: const Icon(Icons.badge_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    isExpanded: true,
                    value: _selectedId,
                    items: _employees.map((e) => DropdownMenuItem(
                      value: e['_id'] as String,
                      child: Text('${e['fullName'] ?? ''} (${e['employeeNumber'] ?? ''})', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedId = v),
                    validator: (_) => _selectedId == null ? l10n.requiredField : null,
                  ),
          ),
          const GapH(12),
          _SectionCard(
            title: l10n.date,
            icon: Icons.calendar_month_rounded,
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.date,
                        prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      controller: TextEditingController(text: DateFormat('EEE, MMM d, yyyy').format(_selectedDate)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                    ),
                  ),
                ]),
                const GapH(12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'morning', label: Text('Morning'), icon: Icon(Icons.wb_sunny_rounded, size: 16)),
                    ButtonSegment(value: 'evening', label: Text('Evening'), icon: Icon(Icons.nightlight_round, size: 16)),
                  ],
                  selected: {_period},
                  onSelectionChanged: (v) => setState(() => _period = v.first),
                ),
              ],
            ),
          ),
          const GapH(12),
          _SectionCard(
            title: '${l10n.checkIn} & ${l10n.checkOut}',
            icon: Icons.schedule_rounded,
            child: Row(children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: l10n.checkIn,
                    prefixIcon: const Icon(Icons.login_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  controller: TextEditingController(text: _checkInTime.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _checkInTime);
                    if (picked != null) setState(() => _checkInTime = picked);
                  },
                ),
              ),
              const GapW(12),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: l10n.checkOut,
                    prefixIcon: Icon(_hasCheckOut ? Icons.logout_rounded : Icons.add_circle_outline_rounded, size: 20),
                    suffixIcon: _hasCheckOut
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => setState(() { _hasCheckOut = false; _checkOutTime = null; }),
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  controller: TextEditingController(text: _checkOutTime?.format(context) ?? ''),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _checkOutTime ?? TimeOfDay(hour: _checkInTime.hour + 4, minute: 0),
                    );
                    if (picked != null) setState(() { _checkOutTime = picked; _hasCheckOut = true; });
                  },
                ),
              ),
            ]),
          ),
          const GapH(24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded, size: 20),
                      const GapW(8),
                      Text(l10n.save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: AppColors.indigo),
              const GapW(8),
              Text(title, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
            ]),
            const GapH(12),
            child,
          ],
        ),
      ),
    );
  }
}
