class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  String status;
  final String userId;
  String? categoryId;
  String? programId;
  final DateTime? createdAt;
  DateTime? updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.userId,
    this.categoryId,
    this.programId,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // id handling
    String taskId;
    if (json.containsKey('id') && json['id'] != null) {
      taskId = json['id'].toString();
    } else if (json.containsKey('_id')) {
      taskId = json['_id'] is Map ? json['_id']['\$oid'] : json['_id'].toString();
    } else {
      taskId = '';
    }

    return Task(
      id: taskId,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dueDate: json['dueDate'] is Map
          ? DateTime.parse(json['dueDate']['\$date'])
          : DateTime.parse(json['dueDate']),
      status: json['status']?.toString() ?? 'pending',
      userId: json['userId'] is Map 
          ? json['userId']['\$oid'] 
          : (json['userId']?.toString() ?? ''),
      categoryId: json['categoryId'] is Map 
          ? json['categoryId']['\$oid'] 
          : json['categoryId']?.toString(),
      programId: json['programId'] is Map
          ? json['programId']['\$oid']
          : json['programId']?.toString(),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Map
              ? DateTime.parse(json['createdAt']['\$date'])
              : DateTime.parse(json['createdAt']))
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Map
              ? DateTime.parse(json['updatedAt']['\$date'])
              : DateTime.parse(json['updatedAt']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': {'\$oid': id},
      'title': title,
      'description': description,
      'dueDate': {'\$date': dueDate.toIso8601String()},
      'status': status,
      'userId': {'\$oid': userId},
      if (categoryId != null) 'categoryId': {'\$oid': categoryId!},
      if (programId != null) 'programId': {'\$oid': programId!},
      'createdAt': createdAt != null ? {'\$date': createdAt!.toIso8601String()} : null,
      'updatedAt': updatedAt != null ? {'\$date': updatedAt!.toIso8601String()} : null,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? userId,
    String? categoryId,
    String? programId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      programId: programId ?? this.programId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
