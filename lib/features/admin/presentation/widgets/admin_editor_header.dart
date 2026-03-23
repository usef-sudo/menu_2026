import "package:flutter/material.dart";

/// Title row + close control for modal admin editors (consistent with categories / facilities).
class AdminEditorHeader extends StatelessWidget {
  const AdminEditorHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.submitting = false,
  });

  final String title;
  final VoidCallback onClose;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: theme.textTheme.titleLarge),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: submitting ? null : onClose,
        ),
      ],
    );
  }
}
