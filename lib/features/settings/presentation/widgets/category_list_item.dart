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
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1C1B1F),
              ),
            ),
          ),
          if (isDeletable)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Color(0xFFB3261E)),
              tooltip: 'Delete category',
            ),
        ],
      ),
    );
  }
}
