import 'package:flutter/material.dart';
import '../../core/theme/color_tokens.dart';

/// Empty state widget for lists with no data.
class AppEmptyStateWidget extends StatelessWidget {
  const AppEmptyStateWidget({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              color: FortunaColors.onSurfaceVariant,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: FortunaColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
