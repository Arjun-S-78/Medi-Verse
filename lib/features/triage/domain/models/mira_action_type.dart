/// MediVerse MIRA Action Types corresponding to the dataset's action definitions.
enum MiraActionType {
  searchHospital,
  searchClinic,
  searchPharmacy,
  searchDoctor,
  bookDoctor,
  cancelAppointment,
  rescheduleAppointment,
  checkAppointment,
  callAmbulance,
  startTriage,
  symptomGuidance,
  healthGuidance,
  medicationSafetyCheck,
  setMedicationReminder,
  emergencyProtocol,
  respondGreeting,
  respondIdentity,
  respondCapabilities,
  respondThanks,
  supportiveConversation,
  clarifyRequest,
  repeatLastResponse,
  stopCurrentAction;

  /// Parse raw string action from dataset or backend to enum value.
  static MiraActionType fromString(String rawAction) {
    switch (rawAction.toUpperCase().trim()) {
      case 'SEARCH_HOSPITAL':
        return MiraActionType.searchHospital;
      case 'SEARCH_CLINIC':
        return MiraActionType.searchClinic;
      case 'SEARCH_PHARMACY':
        return MiraActionType.searchPharmacy;
      case 'SEARCH_DOCTOR':
        return MiraActionType.searchDoctor;
      case 'BOOK_DOCTOR':
        return MiraActionType.bookDoctor;
      case 'CANCEL_APPOINTMENT':
        return MiraActionType.cancelAppointment;
      case 'RESCHEDULE_APPOINTMENT':
        return MiraActionType.rescheduleAppointment;
      case 'CHECK_APPOINTMENT':
        return MiraActionType.checkAppointment;
      case 'CALL_AMBULANCE':
        return MiraActionType.callAmbulance;
      case 'START_TRIAGE':
        return MiraActionType.startTriage;
      case 'SYMPTOM_GUIDANCE':
        return MiraActionType.symptomGuidance;
      case 'HEALTH_GUIDANCE':
        return MiraActionType.healthGuidance;
      case 'MEDICATION_SAFETY_CHECK':
        return MiraActionType.medicationSafetyCheck;
      case 'SET_MEDICATION_REMINDER':
        return MiraActionType.setMedicationReminder;
      case 'EMERGENCY_PROTOCOL':
        return MiraActionType.emergencyProtocol;
      case 'RESPOND_GREETING':
        return MiraActionType.respondGreeting;
      case 'RESPOND_IDENTITY':
        return MiraActionType.respondIdentity;
      case 'RESPOND_CAPABILITIES':
        return MiraActionType.respondCapabilities;
      case 'RESPOND_THANKS':
        return MiraActionType.respondThanks;
      case 'SUPPORTIVE_CONVERSATION':
        return MiraActionType.supportiveConversation;
      case 'REPEAT_LAST_RESPONSE':
        return MiraActionType.repeatLastResponse;
      case 'STOP_CURRENT_ACTION':
        return MiraActionType.stopCurrentAction;
      case 'CLARIFY_REQUEST':
      default:
        return MiraActionType.clarifyRequest;
    }
  }

  /// Whether this action indicates an active external app navigation / service execution.
  bool get isMediVerseServiceAction {
    switch (this) {
      case MiraActionType.searchHospital:
      case MiraActionType.searchClinic:
      case MiraActionType.searchPharmacy:
      case MiraActionType.searchDoctor:
      case MiraActionType.bookDoctor:
      case MiraActionType.cancelAppointment:
      case MiraActionType.rescheduleAppointment:
      case MiraActionType.checkAppointment:
      case MiraActionType.callAmbulance:
      case MiraActionType.startTriage:
      case MiraActionType.setMedicationReminder:
        return true;
      default:
        return false;
    }
  }
}
