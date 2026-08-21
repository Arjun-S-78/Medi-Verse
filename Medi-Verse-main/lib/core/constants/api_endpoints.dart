abstract class ApiEndpoints {
  static const String baseUrl = 'https://api.mediverse.health/v1';

  // Auth
  static const String login = '/auth/login';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';

  // Triage & AI Nurse
  static const String assessTriage = '/triage/assess';
  static const String calculateRisk = '/triage/calculate-risk';
  static const String triageResult = '/triage/result';
  static const String triageHistory = '/triage/history';

  // Emergency & Dispatch
  static const String sosTrigger = '/emergency/sos-trigger';
  static const String confirmDispatch = '/emergency/confirm-dispatch';
  static const String searchingAmbulance = '/ambulance/search';
  static const String ambulanceAssigned = '/ambulance/assigned';
  static const String completeHandover = '/emergency/complete-handover';

  // Hospitals
  static const String nearbyHospitals = '/hospitals/nearby';
  static const String hospitalSearch = '/hospitals/search';
  static const String hospitalDetail = '/hospitals/';

  // Patient Profile & Vitals
  static const String patientProfile = '/patient/profile';
  static const String healthPassport = '/patient/health-passport';
  static const String patientVitals = '/patient/vitals';
  static const String iceContacts = '/patient/ice-contacts';
}
