import 'package:flutter/material.dart';

/// A single category row with an optional delete button.
/// Used in SettingsScreen to display expense/income categories.
class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    super.key,
    required this.name,
    required this.isDeletable,
    required this.onDelete,
  });

  final String name;
  final bool isDeletable;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (isDeletable)
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              tooltip: 'Delete category',
            ),
        ],
      ),
    );
  }
}
