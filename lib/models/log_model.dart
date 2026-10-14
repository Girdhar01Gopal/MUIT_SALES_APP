class LogModel {
  final String id;
  final String userId;
  final String userName;
  final String actionType; // CALL, WHATSAPP, VISIT, APP_USAGE, STATUS_CHANGE, LOGIN
  final String description;
  final String timestamp;
  final Map<String, dynamic>? extraData;

  LogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.actionType,
    required this.description,
    required this.timestamp,
    this.extraData,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      actionType: json['action_type'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] ?? '',
      extraData: json['extra_data'] != null
          ? Map<String, dynamic>.from(json['extra_data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'user_name': userName,
    'action_type': actionType,
    'description': description,
    'timestamp': timestamp,
    'extra_data': extraData,
  };
}