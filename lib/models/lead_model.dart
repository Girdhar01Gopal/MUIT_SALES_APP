class LeadModel {
  final int id;
  final String name;
  final String phone;
  final String course;
  final String status; // Enquiry / Follow-up / Admission
  final String priority; // Hot / Warm / Cold
  final String source; // School Visit, Coaching, Walk-in, Fair, Online
  final String campus; // Lucknow, Noida
  final String stream; // PCM, PCB, Commerce, Arts, etc.
  final String schoolCollege;
  final String followUpDate;
  final String campusVisitDate;
  final String remarks;

  LeadModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.course,
    required this.status,
    this.priority = 'Warm',
    this.source = 'School Visit',
    this.campus = 'Lucknow',
    this.stream = '',
    this.schoolCollege = '',
    this.followUpDate = '',
    this.campusVisitDate = '',
    this.remarks = '',
  });

  LeadModel copyWith({
    String? status,
    String? priority,
    String? followUpDate,
    String? campusVisitDate,
    String? remarks,
  }) {
    return LeadModel(
      id: id,
      name: name,
      phone: phone,
      course: course,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      source: source,
      campus: campus,
      stream: stream,
      schoolCollege: schoolCollege,
      followUpDate: followUpDate ?? this.followUpDate,
      campusVisitDate: campusVisitDate ?? this.campusVisitDate,
      remarks: remarks ?? this.remarks,
    );
  }

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? 0,
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      course: (json['course'] ?? '').toString(),
      status: (json['status'] ?? 'Enquiry').toString(),
      priority: (json['priority'] ?? 'Warm').toString(),
      source: (json['source'] ?? 'School Visit').toString(),
      campus: (json['campus'] ?? 'Lucknow').toString(),
      stream: (json['stream'] ?? '').toString(),
      schoolCollege: (json['school_college'] ?? '').toString(),
      followUpDate: (json['follow_up_date'] ?? '').toString(),
      campusVisitDate: (json['campus_visit_date'] ?? '').toString(),
      remarks: (json['remarks'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'course': course,
    'status': status,
    'priority': priority,
    'source': source,
    'campus': campus,
    'stream': stream,
    'school_college': schoolCollege,
    'follow_up_date': followUpDate,
    'campus_visit_date': campusVisitDate,
    'remarks': remarks,
  };
}