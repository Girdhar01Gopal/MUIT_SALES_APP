class FeesModel {
  final String course;
  final String duration;
  final int tuitionFee; // per year
  final int admissionFee; // one time
  final int hostelFee; // per year, 0 = hostel nahi

  FeesModel({
    required this.course,
    required this.duration,
    required this.tuitionFee,
    required this.admissionFee,
    this.hostelFee = 0,
  });

  // Pehle saal ka kul kharcha (hostel alag se)
  int get firstYearTotal => tuitionFee + admissionFee;

  static int _toInt(dynamic v) => int.tryParse(v.toString()) ?? 0;

  factory FeesModel.fromJson(Map<String, dynamic> json) {
    return FeesModel(
      course: (json['course'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      tuitionFee: _toInt(json['tuition_fee']),
      admissionFee: _toInt(json['admission_fee']),
      hostelFee: _toInt(json['hostel_fee']),
    );
  }
}