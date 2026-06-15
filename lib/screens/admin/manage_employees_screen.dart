import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/realtime_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/skeletons/skeleton_widget.dart';
import 'face_enrollment_screen.dart';

class ManageEmployeesScreen extends StatefulWidget {
  const ManageEmployeesScreen({super.key});

  @override
  State<ManageEmployeesScreen> createState() => _ManageEmployeesScreenState();
}

class _ManageEmployeesScreenState extends State<ManageEmployeesScreen> {
  final ApiService _api = ApiService();
  final RealtimeService _realtime = RealtimeService();
  List<dynamic> _employees = [];
  bool _isLoading = true;

  List<dynamic> _working = [];
  bool _isLoadingLive = true;
  Timer? _refreshTimer;
  StreamSubscription? _attSub;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _loadLiveEmployees();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => _loadLiveEmployees());
    _attSub = _realtime.onAttendanceUpdated.listen((_) => _loadLiveEmployees());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _attSub?.cancel();
    super.dispose();
  }

  Future<void> _loadLiveEmployees() async {
    try {
      final response = await _api.get('/admin/live-employees');
      if (!mounted) return;
      setState(() {
        _working = List<dynamic>.from(response['working'] ?? []);
        _isLoadingLive = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingLive = false);
    }
  }

  Future<void> _loadEmployees() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/employees');
      if (!mounted) return;
      setState(() {
        _employees = response['employees'] ?? [];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ── Add employee — two-step mandatory flow ───────────────────────────────────

  Future<void> _addEmployee() async {
    // Step 1: collect text fields
    final formData = await _showEmployeeDialog();
    if (formData == null || !mounted) return;

    // Step 2: mandatory face enrollment — cannot be skipped
    final descriptors = await Navigator.push<List<List<double>>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FaceEnrollmentScreen(employeeName: formData['fullName'] as String),
      ),
    );

    if (!mounted) return;
    if (descriptors == null || descriptors.isEmpty) {
      showError(context,
          AppLocalizations.of(context).faceEnrollmentCancelled);
      return;
    }

    // Step 3: POST with both form data + descriptors
    try {
      final resp = await _api.post('/employees', {
        'fullName': formData['fullName'],
        'employeeNumber': formData['employeeNumber'],
        'password': formData['password'],
        'faceDescriptors': descriptors,
      }, requiresAuth: true);

      _loadEmployees();
      if (mounted) showSuccess(context, AppLocalizations.of(context).employeeAddedWFace);
      debugPrint('[AddEmployee] Success: $resp');
    } catch (e) {
      if (mounted) {
        showError(context, e.toString().replaceFirst('Exception: ',
            ''));
        debugPrint('[AddEmployee] Error details: $e');
      }
    }
  }

  // ── Edit employee (text fields only) ────────────────────────────────────────

  Future<void> _editEmployee(Map<String, dynamic> employee) async {
    final result = await _showEmployeeDialog(employee: employee);
    if (result == null || !mounted) return;
    try {
      await _api.put('/employees/${employee['id'] ?? employee['_id']}', result);
      _loadEmployees();
      if (mounted) showSuccess(context, AppLocalizations.of(context).employeeUpdated);
    } catch (e) {
      if (mounted) {
        showError(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  // ── Re-enroll face for existing employee ────────────────────────────────────

  Future<void> _reenrollFace(Map<String, dynamic> employee) async {
    final employeeId = employee['id'] ?? employee['_id'];
    final name = employee['fullName'] ?? 'Employee';

    final descriptors = await Navigator.push<List<List<double>>>(
      context,
      MaterialPageRoute(
        builder: (_) => FaceEnrollmentScreen(employeeName: name),
      ),
    );

    if (!mounted) return;
    if (descriptors == null || descriptors.isEmpty) {
      showError(context, AppLocalizations.of(context).faceReenrollmentCancelled);
      return;
    }

    try {
      await _api.post(
        '/employees/enroll-face/$employeeId',
        {'faceDescriptors': descriptors},
        requiresAuth: true,
      );
      _loadEmployees();
      if (mounted) showSuccess(context, 'Face re-enrolled for $name ✓');
    } catch (e) {
      if (mounted) {
        showError(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  // ── Delete employee ──────────────────────────────────────────────────────────

  Future<void> _deleteEmployee(Map<String, dynamic> employee) async {
    final confirmed = await confirmDialog(
      context,
      title: AppLocalizations.of(context).deleteEmployee,
      message: 'Delete ${employee['fullName']}?',
      confirmLabel: AppLocalizations.of(context).delete,
      confirmColor: Colors.red,
    );
    if (!confirmed || !mounted) return;
    try {
      await _api.delete('/employees/${employee['id'] ?? employee['_id']}');
      _loadEmployees();
      if (mounted) showSuccess(context, AppLocalizations.of(context).employeeDeleted);
    } catch (e) {
      if (mounted) {
        showError(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  // ── Employee form dialog ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _showEmployeeDialog({
    Map<String, dynamic>? employee,
  }) async {
    final nameController =
        TextEditingController(text: employee?['fullName'] ?? '');
    final numberController =
        TextEditingController(text: employee?['employeeNumber'] ?? '');
    final passwordController = TextEditingController();
    final isEdit = employee != null;
    final formKey = GlobalKey<FormState>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.cardWhite,
        surfaceTintColor: Colors.transparent,
        title: Text(isEdit ? l10n.editEmployee : l10n.addEmployee,
          style: AppTypography.h3.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textDark,
          ),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (v) => v?.isEmpty == true ? l10n.required : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: numberController,
                  decoration: InputDecoration(
                    labelText: l10n.employeeNumberLabel,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => v?.isEmpty == true ? l10n.required : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: isEdit
                        ? l10n.newPassword
                        : l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: isEdit
                      ? null
                      : (v) => v?.isEmpty == true ? l10n.required : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final resultData = <String, dynamic>{
                  'fullName': nameController.text.trim(),
                  'employeeNumber': numberController.text.trim(),
                };
                if (passwordController.text.isNotEmpty) {
                  resultData['password'] = passwordController.text;
                }
                Navigator.pop(ctx, resultData);
              }
            },
            icon: Icon(isEdit ? Icons.save : Icons.arrow_forward, size: 18),
            label: Text(isEdit ? l10n.save : l10n.nextCaptureFace),
          ),
        ],
      );
      },
    );

    return result;
  }

  // ── Live Monitoring section ─────────────────────────────────────────────────

  Widget _buildLiveSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    if (_isLoadingLive) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LinearProgressIndicator(),
      );
    }

    return _buildEmployeeList(
      title: l10n.workingNowSection,
      icon: Icons.work_history,
      color: Colors.green,
      employees: _working,
      colorScheme: colorScheme,
    );
  }

  Widget _buildEmployeeList({
    required String title,
    required IconData icon,
    required Color color,
    required List<dynamic> employees,
    required ColorScheme colorScheme,
  }) {
    if (employees.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: color.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                  child: Text('0', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: color.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                  child: Text('${employees.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ]),
              const SizedBox(height: 8),
              ...employees.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(e['fullName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  Text(e['employeeNumber'] ?? '', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11)),
                  const SizedBox(width: 8),
                  Text(_formatTime(e['checkInTime']), style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11)),
                ]),
              )),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final algeria = dt.add(const Duration(hours: 1));
      return DateFormat('HH:mm').format(algeria);
    } catch (_) { return ''; }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentAdminId = context.read<AuthProvider>().employee?.id;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _addEmployee,
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addEmployee),
      ),
      body: _isLoading
          ? const SkeletonList()
          : _employees.isEmpty
              ? EmptyState(
                  icon: Icons.people_outline,
                  title: l10n.noEmployeesFound,
                  subtitle: l10n.addFirstEmployee,
                  actionLabel: l10n.addEmployee,
                  onAction: _addEmployee,
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      _loadEmployees(),
                      _loadLiveEmployees(),
                    ]);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _employees.length + 1,
                    itemBuilder: (ctx, i) {
                      if (i == 0) return _buildLiveSection();
                      final emp = _employees[i - 1];
                      final isActive = emp['isActive'] ?? true;
                      final role = emp['role'] ?? 'employee';
                      final isAdmin = role == 'admin';
                      final faceEnrolled = emp['faceEnrolled'] ?? false;
                      final isSelf =
                          (emp['id'] ?? emp['_id']).toString() ==
                              currentAdminId;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        color: isAdmin
                            ? colorScheme.primaryContainer
                                .withValues(alpha: 0.35)
                            : null,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                backgroundColor: isAdmin
                                    ? colorScheme.primary
                                        .withValues(alpha: 0.2)
                                    : (isActive
                                            ? Colors.green
                                            : Colors.red)
                                        .withValues(alpha: 0.15),
                                child: Icon(
                                  isAdmin
                                      ? Icons.shield
                                      : Icons.person,
                                  color: isAdmin
                                      ? colorScheme.primary
                                      : (isActive
                                          ? Colors.green
                                          : Colors.red),
                                  size: isAdmin ? 22 : 20,
                                ),
                              ),
                              // Face-enrolled badge (employees only)
                              if (!isAdmin)
                                Positioned(
                                  right: -3,
                                  bottom: -3,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: faceEnrolled
                                          ? Colors.green
                                          : Colors.orange,
                                      border: Border.all(
                                          color: colorScheme.surface, width: 1.5),
                                    ),
                                    child: Icon(
                                      faceEnrolled
                                          ? Icons.face
                                          : Icons.face_retouching_off,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            emp['fullName'] ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isAdmin
                                    ? colorScheme.primary
                                    : colorScheme.onSurface),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${emp['employeeNumber'] ?? ''} · $role',
                                    style: TextStyle(
                                        color: isAdmin
                                            ? colorScheme.primary
                                                .withValues(alpha: 0.7)
                                            : colorScheme.onSurfaceVariant,
                                        fontSize: 12),
                                  ),
                                  if (isAdmin)
                                    Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        l10n.adminRole,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (!isAdmin) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      faceEnrolled
                                          ? Icons.check_circle_rounded
                                          : Icons.warning_amber_rounded,
                                      size: 12,
                                      color: faceEnrolled
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      faceEnrolled
                                          ? l10n.faceEnrolled
                                          : l10n.faceNotEnrolled,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: faceEnrolled
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            onSelected: (v) {
                              if (v == 'edit') _editEmployee(emp);
                              if (v == 'enroll') _reenrollFace(emp);
                              if (v == 'delete') _deleteEmployee(emp);
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(children: [
                                  const Icon(Icons.edit, size: 16, color: Colors.blue),
                                  const SizedBox(width: 10),
                                  Text(l10n.editDetails),
                                ]),
                              ),
                              if (!isAdmin)
                                PopupMenuItem(
                                  value: 'enroll',
                                  child: Row(children: [
                                    const Icon(Icons.face_retouching_natural,
                                        size: 16, color: Colors.purple),
                                    const SizedBox(width: 10),
                                    Text(l10n.reenrollFace),
                                  ]),
                                ),
                              if (!isSelf)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(children: [
                                    const Icon(Icons.delete,
                                        size: 16, color: Colors.red),
                                    const SizedBox(width: 10),
                                    Text(l10n.delete,
                                        style: TextStyle(color: Colors.red)),
                                  ]),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
