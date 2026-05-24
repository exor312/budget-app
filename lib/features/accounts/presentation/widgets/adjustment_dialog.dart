import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../transactions/data/budget_model.dart';

/// Dialog for adding an adjustment transaction to an account.
class AdjustmentDialog extends StatefulWidget {
  const AdjustmentDialog({
    super.key,
    required this.accountId,
    required this.accountName,
  });

  final String accountId;
  final String accountName;

  @override
  State<AdjustmentDialog> createState() => _AdjustmentDialogState();
}

class _AdjustmentDialogState extends State<AdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isIncome = true;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim().isEmpty
          ? 'Adjustment'
          : _descriptionController.text.trim();

      context.read<BudgetModel>().addTransaction(
            amount: _isIncome ? amount : -amount,
            description: description,
            category: 'Adjustment',
            accountId: widget.accountId,
          );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: FortunaColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Adjust ${widget.accountName}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: FortunaColors.primary,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Income/Expense toggle
            Container(
              decoration: BoxDecoration(
                color: FortunaColors.surfaceContainer,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncome = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isIncome
                              ? FortunaColors.onTertiaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'Income',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isIncome
                                ? FortunaColors.surface
                                : FortunaColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncome = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isIncome
                              ? FortunaColors.error
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'Expense',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: !_isIncome
                                ? FortunaColors.surface
                                : FortunaColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Amount field
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: FortunaColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: FortunaColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return 'Please enter a valid positive amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'e.g. Balance correction',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: FortunaColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: FortunaColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: FortunaColors.onSurfaceVariant),
          ),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: _isIncome
                ? FortunaColors.onTertiaryContainer
                : FortunaColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
