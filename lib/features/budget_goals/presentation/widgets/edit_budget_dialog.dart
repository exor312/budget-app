import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Result returned from EditBudgetDialog.
class EditBudgetResult {
  const EditBudgetResult({required this.name, required this.limit});
  final String name;
  final double limit;
}

/// Dialog for adding a new budget category or editing an existing one.
class EditBudgetDialog extends StatefulWidget {
  const EditBudgetDialog({
    super.key,
    this.initialName,
    this.initialLimit,
    required this.isAdd,
    this.existingNames = const [],
  });

  final String? initialName;
  final double? initialLimit;
  final bool isAdd;
  final List<String> existingNames;

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _limitController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _limitController = TextEditingController(
      text: widget.initialLimit != null
          ? (widget.initialLimit == widget.initialLimit!.roundToDouble()
              ? widget.initialLimit!.toStringAsFixed(0)
              : widget.initialLimit!.toStringAsFixed(2))
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final limit = double.tryParse(_limitController.text.trim()) ?? 0;
    Navigator.of(context).pop(EditBudgetResult(name: name, limit: limit));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isAdd ? 'New Budget' : 'Edit Budget'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Name is required';
                  // Check duplicate (exclude current name when editing)
                  final isDuplicate = widget.existingNames.any(
                    (n) =>
                        n.toLowerCase() == trimmed.toLowerCase() &&
                        n.toLowerCase() != (widget.initialName?.toLowerCase() ?? ''),
                  );
                  if (isDuplicate) return 'Category already exists';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limitController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Limit (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Limit is required';
                  final parsed = double.tryParse(trimmed);
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
