import 'package:flutter/material.dart';

class TemperatureWidget extends StatelessWidget {
  final double temperature;

  const TemperatureWidget({Key? key, required this.temperature}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 5,
            color: Colors.grey.withOpacity(0.3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.thermostat, size: 40, color: Colors.red),
          const SizedBox(width: 10),
          Text(
            "Temperature: ${temperature.toStringAsFixed(1)}°C",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
