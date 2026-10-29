import '../../planning/models/planning_opening_hours.dart';

class Practitioner {
  /// Null inherits the cabinet schedule dynamically; an empty week is explicit.
  final PlanningOpeningHours? workingHours;
  static const appointmentSteps = [15, 20, 30];
  final int appointmentStepMinutes;
  final int appointmentDurationMinutes;
  final String practitionerId;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String? professionalId;
  final String? email;
  final String? phone;
  final bool isActive;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const Practitioner({
    required this.practitionerId,
    this.workingHours,
    this.appointmentStepMinutes = 15,
    this.appointmentDurationMinutes = 45,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.professionalId,
    this.email,
    this.phone,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  }) : assert(
         appointmentDurationMinutes >= 1 && appointmentDurationMinutes <= 840,
       ),
       assert(
         appointmentStepMinutes == 15 ||
             appointmentStepMinutes == 20 ||
             appointmentStepMinutes == 30,
       );

  factory Practitioner.fromMap(Map<String, dynamic> map) {
    return Practitioner(
      practitionerId: map['practitioner_id'] as String,
      appointmentStepMinutes: map['appointment_step_minutes'] as int? ?? 15,
      appointmentDurationMinutes:
          map['appointment_duration_minutes'] as int? ?? 45,
      workingHours: map['working_hours_json'] == null
          ? null
          : PlanningOpeningHours.decode(map['working_hours_json'] as String),
      displayName: map['display_name'] as String,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      professionalId: map['professional_id'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'practitioner_id': practitionerId,
      'appointment_step_minutes': appointmentStepMinutes,
      'appointment_duration_minutes': appointmentDurationMinutes,
      'working_hours_json': workingHours?.encode(),
      'display_name': displayName,
      'first_name': firstName,
      'last_name': lastName,
      'professional_id': professionalId,
      'email': email,
      'phone': phone,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }

  bool get isArchived => archivedAt != null;
}
