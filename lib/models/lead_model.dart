class LeadModel {
  final int id;
  final String name;
  final String phone;
  final String course;
  final String status; // Enquiry / Follow-up / Admission
  final String schoolCollege;
  final String followUpDate;
  final String remarks;

  LeadModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.course,
    required this.status,
    this.schoolCollege = '',
    this.followUpDate = '',
    this.remarks = '',
  });

  LeadModel copyWith({String? status, String? followUpDate}) {
    return LeadModel(
      id: id,
      name: name,
      phone: phone,
      course: course,
      status: status ?? this.status,
      schoolCollege: schoolCollege,
      followUpDate: followUpDate ?? this.followUpDate,
      remarks: remarks,
    );
  }

  // Server ki keys backend ke hisaab se badal lena
  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? 0,
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      course: (json['course'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      schoolCollege: (json['school_college'] ?? '').toString(),
      followUpDate: (json['follow_up_date'] ?? '').toString(),
      remarks: (json['remarks'] ?? '').toString(),
    );
  }
}