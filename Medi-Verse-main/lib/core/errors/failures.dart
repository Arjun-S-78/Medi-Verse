/// Domain-level Mapped Failure objects for MediVerse
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection unavailable. Please check internet connection.',
  });
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode = 401});
}

class TriageAssessmentFailure extends Failure {
  const TriageAssessmentFailure({required super.message});
}

class AmbulanceDispatchFailure extends Failure {
  const AmbulanceDispatchFailure({required super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Emergency services have been alerted.',
  });
}
