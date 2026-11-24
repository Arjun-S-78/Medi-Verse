import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../domain/models/mira_action_type.dart';

/// Execution payload returned when an action is executed.
class MiraActionResult {
  final bool success;
  final String routeTarget;
  final String userFeedbackText;
  final Map<String, dynamic> extraData;

  const MiraActionResult({
    required this.success,
    required this.routeTarget,
    required this.userFeedbackText,
    this.extraData = const {},
  });
}

/// Controlled Action/Tool Registry for MIRA inside MediVerse.
///
/// Ensures LLM/Intent Engine cannot directly run arbitrary code,
/// executing only allowlisted MediVerse UI actions and service navigations.
class MiraActionRegistry {
  /// Execute allowlisted MediVerse action safely.
  static MiraActionResult executeAction({
    required BuildContext context,
    required MiraActionType actionType,
    Map<String, dynamic> entities = const {},
  }) {
    switch (actionType) {
      case MiraActionType.searchHospital:
      case MiraActionType.searchClinic:
      case MiraActionType.searchPharmacy:
        context.push(RouteNames.hospitalSearch);
        return const MiraActionResult(
          success: true,
          routeTarget: RouteNames.hospitalSearch,
          userFeedbackText: "Opening MediVerse Hospital Radar to display nearby facilities.",
        );

      case MiraActionType.searchDoctor:
      case MiraActionType.bookDoctor:
        final specialty = entities['specialty'] ?? 'General Physician';
        context.push(RouteNames.doctorBooking);
        return MiraActionResult(
          success: true,
          routeTarget: RouteNames.doctorBooking,
          userFeedbackText: "Opening doctor booking for $specialty specialists.",
          extraData: {'specialty': specialty},
        );

      case MiraActionType.callAmbulance:
      case MiraActionType.emergencyProtocol:
        context.push(RouteNames.liveTracking);
        return const MiraActionResult(
          success: true,
          routeTarget: RouteNames.liveTracking,
          userFeedbackText: "Accessing MediVerse Emergency Fleet GPS Radar for ambulance coordination.",
        );

      case MiraActionType.cancelAppointment:
      case MiraActionType.rescheduleAppointment:
      case MiraActionType.checkAppointment:
        context.push(RouteNames.doctorBooking);
        return const MiraActionResult(
          success: true,
          routeTarget: RouteNames.doctorBooking,
          userFeedbackText: "Navigating to your MediVerse Appointments dashboard.",
        );

      case MiraActionType.setMedicationReminder:
      case MiraActionType.medicationSafetyCheck:
        context.push(RouteNames.healthPassport);
        return const MiraActionResult(
          success: true,
          routeTarget: RouteNames.healthPassport,
          userFeedbackText: "Opening your MediVerse Health Passport & Medication Tracker.",
        );

      case MiraActionType.startTriage:
        context.push(RouteNames.triageAssess);
        return const MiraActionResult(
          success: true,
          routeTarget: RouteNames.triageAssess,
          userFeedbackText: "Starting interactive symptom assessment.",
        );

      case MiraActionType.respondGreeting:
      case MiraActionType.respondIdentity:
      case MiraActionType.respondCapabilities:
      case MiraActionType.respondThanks:
      case MiraActionType.supportiveConversation:
      case MiraActionType.symptomGuidance:
      case MiraActionType.healthGuidance:
      case MiraActionType.clarifyRequest:
      case MiraActionType.repeatLastResponse:
      case MiraActionType.stopCurrentAction:
        return const MiraActionResult(
          success: true,
          routeTarget: '',
          userFeedbackText: '',
        );
    }
  }
}
