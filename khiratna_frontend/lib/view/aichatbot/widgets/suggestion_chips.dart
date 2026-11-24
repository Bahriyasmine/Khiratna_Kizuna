import 'package:flutter/material.dart';

const _green = Color(0xFF0F9D58);

class SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelect;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final s in suggestions)
          ActionChip(
            label: Text(s),
            labelStyle: const TextStyle(color: _green, fontSize: 13),
            backgroundColor: Colors.white,
            side: BorderSide(color: _green.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => onSelect(s),
          ),
      ],
    );
  }
}