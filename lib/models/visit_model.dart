class VisitModel {
  final String studentName;
  final String phone;
  final String schoolCollege;
  final String course;
  final String status;
  final String remarks;
  final String followUpDate;
  final double lat;
  final double lng;
  final String address;

  VisitModel({
    required this.studentName,
    required this.phone,
    required this.schoolCollege,
    required this.course,
    required this.status,
    required this.remarks,
    required this.followUpDate,
    required this.lat,
    required this.lng,
    required this.address,
  });

  // Server ko ye keys jayengi, backend wale se match kara lena
  Map<String, dynamic> toJson() => {
    'student_name': studentName,
    'phone': phone,
    'school_college': schoolCollege,
    'course': course,
    'status': status,
    'remarks': remarks,
    'follow_up_date': followUpDate,
    'latitude': lat,
    'longitude': lng,
    'address': address,
  };
}