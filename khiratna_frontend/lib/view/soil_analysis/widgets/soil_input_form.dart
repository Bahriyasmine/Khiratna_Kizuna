import 'package:flutter/material.dart';

class SoilInputForm extends StatelessWidget {
  final TextEditingController nitrogenController;
  final TextEditingController phosphorusController;
  final TextEditingController potassiumController;
  final TextEditingController temperatureController;
  final TextEditingController humidityController;
  final TextEditingController phController;
  final TextEditingController rainfallController;
  final bool loading;
  final VoidCallback onAnalyze;

  const SoilInputForm({
    super.key,
    required this.nitrogenController,
    required this.phosphorusController,
    required this.potassiumController,
    required this.temperatureController,
    required this.humidityController,
    required this.phController,
    required this.rainfallController,
    required this.loading,
    required this.onAnalyze,
  });

  Widget _field(String label, TextEditingController c) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      _field('Nitrogen (N)', nitrogenController),
      _field('Phosphorus (P)', phosphorusController),
      _field('Potassium (K)', potassiumController),
      _field('Temperature (°C)', temperatureController),
      _field('Humidity (%)', humidityController),
      _field('pH', phController),
      _field('Rainfall (mm)', rainfallController),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Soil & climate data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            for (final f in fields) ...[f, const SizedBox(height: 12)],
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: loading ? null : onAnalyze,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Analyze'),
            ),
          ],
        ),
      ),
    );
  }
}