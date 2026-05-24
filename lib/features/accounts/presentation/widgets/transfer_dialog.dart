import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../settings/data/account_settings_model.dart';
import '../../../transactions/data/budget_model.dart';

/// Dialog for transferring funds from one account to another.
class TransferDialog extends StatefulWidget {
  const TransferDialog({
    super.key,
    required this.sourceAccountId,
    required this.sourceAccountName,
  });

  final String sourceAccountId;
  final String sourceAccountName;

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _destinationAccountId;

  List<Account> get _destinationAccounts => context
      .read<AccountSettingsModel>()
      .accounts
      .where((a) => a.id != widget.sourceAccountId)
      .toList();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _destinationAccountId != null) {
      final amount = double.parse(_amountController.text);
      final destAccount = context
          .read<AccountSettingsModel>()
          .findById(_destinationAccountId!);

      final budgetModel = context.read<BudgetModel>();
      // Outgoing from source
      budgetModel.addTransaction(
        amount: -amount,
        description: 'Transfer to ${destAccount.name}',
        category: 'Transfer',
        accountId: widget.sourceAccountId,
      );
      // Incoming to destination
      budgetModel.addTransaction(
        amount: amount,
        description:
            'Transfer from ${widget.sourceAccountName}',
        category: 'Transfer',
        accountId: _destinationAccountId!,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final destinations = _destinationAccounts;

    return AlertDialog(
      backgroundColor: cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Transfer from ${widget.sourceAccountName}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (destinations.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add another account in Settings to transfer between accounts.',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Destination account dropdown
              DropdownButtonFormField<String>(
                value: _destinationAccountId,
                decoration: InputDecoration(
                  labelText: 'To Account',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: cs.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: cs.primary, width: 2),
                  ),
                ),
                items: destinations.map((account) {
                  return DropdownMenuItem<String>(
                    value: account.id,
                    child: Text(account.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _destinationAccountId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a destination account';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
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
                        BorderSide(color: cs.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: cs.primary, width: 2),
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
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
        if (destinations.isNotEmpty)
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Transfer'),
          ),
      ],
    );
  }
}
