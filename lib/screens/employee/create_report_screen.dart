import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_report_provider.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../l10n/l10n.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  String _selectedType = 'issue';
  Uint8List? _imageBytes;
  String? _imageBase64;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _buildTypes(AppLocalizations l10n) => [
    {'value': 'issue', 'label': l10n.issue, 'icon': Icons.report_problem, 'color': Colors.red},
    {'value': 'inventory', 'label': l10n.inventory, 'icon': Icons.inventory_2, 'color': Colors.blue},
    {'value': 'feedback', 'label': l10n.feedback, 'icon': Icons.feedback, 'color': Colors.green},
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageBase64 = base64Encode(bytes);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final l10n = AppLocalizations.of(context);
    final provider = context.read<EmployeeReportProvider>();
    final photoToSend = _imageBase64 != null ? 'data:image/jpeg;base64,$_imageBase64' : null;
    final error = await provider.createReport(
      _selectedType,
      _descController.text.trim(),
      photo: photoToSend,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      showError(context, error);
    } else {
      showSuccess(context, l10n.submitted);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newReport)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.reportType, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              ..._buildTypes(l10n).map((t) {
                final val = t['value'] as String;
                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    leading: Icon(t['icon'] as IconData, color: t['color'] as Color),
                    title: Text(t['label'] as String),
                    trailing: Icon(Icons.circle, size: 18, color: _selectedType == val ? t['color'] as Color : Colors.transparent),
                    onTap: () => setState(() => _selectedType = val),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    dense: true,
                  ),
                );
              }),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (v) => v == null || v.trim().isEmpty ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: Text(l10n.addPhoto),
                  ),
                  const SizedBox(width: 12),
                  if (_imageBytes != null)
                    Expanded(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _imageBytes!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() {
                              _imageBytes = null;
                              _imageBase64 = null;
                            }),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.submitReport),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
