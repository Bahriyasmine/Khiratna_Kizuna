import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khiratna_frontend/model/water_forecast.dart';
import 'package:khiratna_frontend/viewmodel/rain_forecast_viewmodel.dart';


class ForecastForm extends StatelessWidget {
  final RainForecastViewModel vm;

  const ForecastForm({
    super.key,
    required this.vm,
  });

  Future<void> _pickStartDate(
    BuildContext context,
  ) async {
    final o = vm.options;
    if (o == null) return;

    final DateTime? picked =
        await showDatePicker(
      context: context,
      firstDate: o.firstDate,
      lastDate: o.lastDate,
      initialDate: vm.start,
    );

    if (picked != null) {
      vm.setStart(picked);
    }
  }

  Future<void> _pickEndDate(
    BuildContext context,
  ) async {
    final o = vm.options;
    if (o == null) return;

    final DateTime? picked =
        await showDatePicker(
      context: context,
      firstDate: o.firstDate,
      lastDate: o.lastDate,
      initialDate: vm.end,
    );

    if (picked != null) {
      vm.setEnd(picked);
    }
  }

  String formatDate(DateTime date) {
    return DateFormat(
      'MMM yyyy',
    ).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final o = vm.options;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(28),
      ),
      child: _buildContent(context, o),
    );
  }

  Widget _buildContent(
    BuildContext context,
    RainfallOptions? o,
  ) {
    if (vm.optionsLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (o == null) {
      return Column(
        children: [
          Text(
            vm.optionsError ??
                "Regions and crops are not loaded.",
            style: const TextStyle(
              color: Colors.red,
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: vm.loadOptions,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      );
    }

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: vm.region,
          isExpanded: true,
          decoration:
              const InputDecoration(
            labelText: "Region",
          ),
          items: o.regions
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(r),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              vm.setRegion(value);
            }
          },
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: vm.cropId,
          isExpanded: true,
          decoration:
              const InputDecoration(
            labelText: "Crop",
          ),
          items: o.crops
              .map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              vm.setCrop(value);
            }
          },
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () =>
                    _pickStartDate(context),
                child: InputDecorator(
                  decoration:
                      const InputDecoration(
                    labelText:
                        "Start Month",
                  ),
                  child: Text(
                    formatDate(vm.start),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: InkWell(
                onTap: () =>
                    _pickEndDate(context),
                child: InputDecorator(
                  decoration:
                      const InputDecoration(
                    labelText: "End Month",
                  ),
                  child: Text(
                    formatDate(vm.end),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed:
                vm.loading ? null : vm.generate,
            icon: vm.loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.auto_graph,
                  ),
            label: const Text(
              "Generate Forecast",
            ),
          ),
        ),
      ],
    );
  }
}