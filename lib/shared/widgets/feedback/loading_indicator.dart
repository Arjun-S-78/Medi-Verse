import 'package:flutter/material.dart';
import 'loading_widget.dart';

/// Legacy wrapper for LoadingWidget
class MedicalLoadingIndicator extends StatelessWidget {
  final String? message;

  const MedicalLoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(message: message);
  }
}
