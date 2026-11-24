import 'package:flutter/material.dart';

class StatsDesktopSection extends StatelessWidget {
  const StatsDesktopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: const [
          Expanded(
            child: _StatCard(
              "98%",
              "Prediction Accuracy",
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _StatCard(
              "24",
              "Regions",
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _StatCard(
              "10+",
              "Years of Data",
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _StatCard(
              "4",
              "AI Services",
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String title;

  const _StatCard(
    this.value,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.04),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.green,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}