import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Result returned from SavingsGoalDialog.
class SavingsGoalResult {
  const SavingsGoalResult({required this.name, required this.targetAmount});
  final String name;
  final double targetAmount;
}

/// Dialog for adding a new savings goal or editing an existing one.
class SavingsGoalDialog extends StatefulWidget {
  const SavingsGoalDialog({
    super.key,
    this.initialName,
    this.initialTarget,
    required this.isAdd,
    this.existingNames = const [],
  });

  final String? initialName;
  final double? initialTarget;
  final bool isAdd;
  final List<String> existingNames;

  @override
  State<SavingsGoalDialog> createState() => _SavingsGoalDialogState();
}

class _SavingsGoalDialogState extends State<SavingsGoalDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _targetController = TextEditingController(
      text: widget.initialTarget != null
          ? (widget.initialTarget == widget.initialTarget!.roundToDouble()
              ? widget.initialTarget!.toStringAsFixed(0)
              : widget.initialTarget!.toStringAsFixed(2))
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final target = double.tryParse(_targetController.text.trim()) ?? 0;
    Navigator.of(context).pop(SavingsGoalResult(name: name, targetAmount: target));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isAdd ? 'New Savings Goal' : 'Edit Savings Goal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Name is required';
                  final isDuplicate = widget.existingNames.any(
                    (n) =>
                        n.toLowerCase() == trimmed.toLowerCase() &&
                        n.toLowerCase() != (widget.initialName?.toLowerCase() ?? ''),
                  );
                  if (isDuplicate) return 'Goal already exists';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Target is required';
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
