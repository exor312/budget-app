import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Result returned from EditBudgetDialog.
class EditBudgetResult {
  const EditBudgetResult({required this.name, required this.limit});
  final String name;
  final double limit;
}

/// Dialog for adding a new budget category or editing an existing one.
/// When adding, the category name is selected from a dropdown of existing
/// expense categories (not free-text) to ensure budgets are only created
/// for real expense categories.
class EditBudgetDialog extends StatefulWidget {
  const EditBudgetDialog({
    super.key,
    this.initialName,
    this.initialLimit,
    required this.isAdd,
    this.existingNames = const [],
    this.availableCategories = const [],
  });

  final String? initialName;
  final double? initialLimit;
  final bool isAdd;
  final List<String> existingNames;
  final List<String> availableCategories;

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  late final TextEditingController _limitController;
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;

  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialName;
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
    final limit = double.tryParse(_limitController.text.trim()) ?? 0;
    final name = widget.isAdd
        ? (_selectedCategory ?? '')
        : (_selectedCategory ?? widget.initialName ?? '');
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
              _buildCategoryField(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limitController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Limit (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Limit is required';
                  final parsed = double.tryParse(trimmed);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount';
                  }
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
          onPressed:
              widget.isAdd && widget.availableCategories.isEmpty
                  ? null
                  : _onSave,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    if (widget.isAdd) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: widget.availableCategories.contains(_selectedCategory)
                ? _selectedCategory
                : null,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: widget.availableCategories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
          if (widget.availableCategories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'All expense categories already have budgets. '
                'Add new expense categories in Settings first.',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      );
    }
    // Edit mode: show category name as read-only
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Category Name',
        border: OutlineInputBorder(),
      ),
      enabled: false,
    );
  }
}
