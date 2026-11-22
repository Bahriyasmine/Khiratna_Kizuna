import 'package:flutter/material.dart';

class CtaDesktopSection extends StatelessWidget {
  const CtaDesktopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 60,
        vertical: 50,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D3B24),
            Color(0xFF2E7D32),
          ],
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Ready to transform your farm?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  "Start using AI-powered insights to improve productivity, optimize water consumption and maximize profitability.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 60),

          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 80,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: 220,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.white,
                      foregroundColor:
                          const Color(
                              0xFF2E7D32),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                16),
                      ),
                    ),
                    child: const Text(
                      "Explore Services",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}