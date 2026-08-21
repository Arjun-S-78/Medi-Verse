import 'package:flutter/material.dart';
import 'emergency_button.dart';

/// Legacy export alias pointing to EmergencyButton
class EmergencySosButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final double size;

  const EmergencySosButton({
    super.key,
    required this.onTap,
    this.label = 'SOS',
    this.size = 130.0,
  });

  @override
  Widget build(BuildContext context) {
    return EmergencyButton(
      onTap: onTap,
      label: label,
      size: size,
    );
  }
}
