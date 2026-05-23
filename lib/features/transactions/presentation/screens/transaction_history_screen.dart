import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../transactions/data/budget_model.dart';
import '../widgets/transaction_list_item.dart';

/// Transaction history screen — view and delete transactions.
class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  static const String routePath = '/transactions';
  static const String routeName = 'Transactions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FortunaColors.surface,
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: TextStyle(
            color: FortunaColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: FortunaColors.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        iconTheme: const IconThemeData(color: FortunaColors.onSurface),
      ),
      body: Consumer<BudgetModel>(
        builder: (context, model, _) {
          if (model.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    color: FortunaColors.onSurfaceVariant,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      color: FortunaColors.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first transaction',
                    style: TextStyle(
                      color: FortunaColors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final reversedTransactions = model.transactions.reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: reversedTransactions.length,
            itemBuilder: (context, index) {
              final transaction = reversedTransactions[index];
              return TransactionListItem(
                transaction: transaction,
                onDelete: () {
                  model.removeTransaction(index);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        backgroundColor: FortunaColors.primary,
        foregroundColor: FortunaColors.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: const _TransactionFormContent(),
      ),
    );
  }
}

class _TransactionFormContent extends StatefulWidget {
  const _TransactionFormContent();

  @override
  State<_TransactionFormContent> createState() => _TransactionFormContentState();
}

class _TransactionFormContentState extends State<_TransactionFormContent> {
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

  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;

      context.read<BudgetModel>().addTransaction(
            amount: _isIncome ? amount : -amount,
            description: description,
          );

      _amountController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FortunaColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: FortunaColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Type:'),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Income'),
                  selected: _isIncome,
                  selectedColor: FortunaColors.secondaryContainer,
                  onSelected: (selected) {
                    setState(() => _isIncome = selected);
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Expense'),
                  selected: !_isIncome,
                  selectedColor: FortunaColors.secondaryContainer,
                  onSelected: (selected) {
                    setState(() => _isIncome = !selected);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _addTransaction,
                child: const Text('Add Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
