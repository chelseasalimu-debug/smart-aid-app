class Appointment {
  final String id;
  final String serviceType; // e.g. "General Consultation"
  final DateTime dateTime;
  final String reason; // user's notes
  final String location; // e.g. "CUT Campus Clinic"
  final bool isCompleted;

  Appointment({
    required this.id,
    required this.serviceType,
    required this.dateTime,
    required this.reason,
    required this.location,
    this.isCompleted = false,
  });

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceType': serviceType,
    'dateTime': dateTime.toIso8601String(),
    'reason': reason,
    'location': location,
    'isCompleted': isCompleted,
  };

  // Build from JSON when loading
  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'],
    serviceType: json['serviceType'],
    dateTime: DateTime.parse(json['dateTime']),
    reason: json['reason'],
    location: json['location'],
    isCompleted: json['isCompleted'] ?? false,
  );
}
