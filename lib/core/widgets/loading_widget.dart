import 'package:flutter/material.dart';

/// Centered loading indicator widget.
class AppLoadingWidget extends StatelessWidget {
  AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
