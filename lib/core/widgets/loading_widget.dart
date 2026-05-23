import 'package:flutter/material.dart';
import '../../core/theme/color_tokens.dart';

/// Centered loading indicator widget.
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: FortunaColors.primary,
      ),
    );
  }
}
