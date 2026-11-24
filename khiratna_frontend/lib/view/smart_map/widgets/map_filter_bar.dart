import 'package:flutter/material.dart';
import 'package:khiratna_frontend/viewmodel/smart_maps_viewmodel.dart';
import 'package:provider/provider.dart';

class SoilFilterBar extends StatelessWidget {
  final String selectedParameter;
  final String selectedGovernorate;

  final List<String> governorates;

  final ValueChanged<String?> onParameterChanged;
  final ValueChanged<String?> onGovernorateChanged;

  const SoilFilterBar({
    super.key,
    required this.selectedParameter,
    required this.selectedGovernorate,
    required this.governorates,
    required this.onParameterChanged,
    required this.onGovernorateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SmartMapsViewModel>();

    // Backend list when available, otherwise what the view passed in
    final govList = vm.governorates.isNotEmpty ? vm.governorates : governorates;

    final parameterDropdown = _FilterDropdown(
      label: 'Soil Parameter',
      value: selectedParameter,
      items: [
        for (final p in vm.parameters)
          DropdownMenuItem(value: p.value, child: Text(p.label)),
      ],
      onChanged: onParameterChanged,
    );

    final governorateDropdown = _FilterDropdown(
      label: 'Governorate',
      value: selectedGovernorate,
      items: [
        for (final g in govList) DropdownMenuItem(value: g, child: Text(g)),
      ],
      onChanged: onGovernorateChanged,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              parameterDropdown,
              const SizedBox(height: 16),
              governorateDropdown,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: parameterDropdown),
            const SizedBox(width: 16),
            Expanded(child: governorateDropdown),
          ],
        );
      },
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Guard: a value that isn't in the list would crash the dropdown
    final exists = items.any((item) => item.value == value);

    return DropdownButtonFormField<String>(
      value: exists ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}