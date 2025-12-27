import 'package:rashad_frontend/models/task.dart';

class Program {
  final String id;
  final String name;
  final String description;
  final String code;
  final List<Task> tasks;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final String adminId;
  final bool isPublic;
  final List<String>? memberIds;
  final List<String>? pendingRequests;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Program({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
    required this.tasks,
    required this.adminId,
    this.isPublic = true,
    this.startDate,
    this.endDate,
    this.status,
    this.memberIds,
    this.pendingRequests,
    this.createdAt,
    this.updatedAt,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    // Backend: _id, name, description, ownerId, isPublic, approvedUsers
    String programId;
    if (json.containsKey('id') && json['id'] != null) {
      programId = json['id'].toString();
    } else if (json.containsKey('_id')) {
      programId = json['_id'] is Map ? json['_id']['\$oid'] : json['_id'].toString();
    } else {
      programId = '';
    }

    String owner;
    if (json.containsKey('ownerId')) {
      owner = json['ownerId'] is Map ? json['ownerId']['\$oid'] : json['ownerId'].toString();
    } else if (json.containsKey('adminId')) {
      owner = json['adminId'] is Map ? json['adminId']['\$oid'] : json['adminId'].toString();
    } else {
      owner = '';
    }

    return Program(
      id: programId,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      code: json['code']?.toString() ?? '', // Backend'de yok ama frontend'de kullanılıyor
      adminId: owner,
      isPublic: json['isPublic'] ?? true,
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((task) => Task.fromJson(task))
              .toList() ??
          [],
      startDate: json['startDate'] != null
          ? (json['startDate'] is Map
              ? DateTime.parse(json['startDate']['\$date'])
              : DateTime.parse(json['startDate']))
          : null,
      endDate: json['endDate'] != null
          ? (json['endDate'] is Map
              ? DateTime.parse(json['endDate']['\$date'])
              : DateTime.parse(json['endDate']))
          : null,
      status: json['status']?.toString(),
      memberIds: json['approvedUsers'] != null
          ? List<String>.from(json['approvedUsers'].map((e) => e.toString()))
          : (json['memberIds'] != null ? List<String>.from(json['memberIds'].map((e) => e.toString())) : null),
      pendingRequests: json['pendingRequests'] != null
          ? List<String>.from(json['pendingRequests'].map((e) => e.toString()))
          : null,
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
      'name': name,
      'description': description,
      'code': code,
      'adminId': {'\$oid': adminId},
      'isPublic': isPublic,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'startDate': startDate != null ? {'\$date': startDate!.toIso8601String()} : null,
      'endDate': endDate != null ? {'\$date': endDate!.toIso8601String()} : null,
      'status': status,
      'memberIds': memberIds,
      'pendingRequests': pendingRequests,
      'createdAt': createdAt != null ? {'\$date': createdAt!.toIso8601String()} : null,
      'updatedAt': updatedAt != null ? {'\$date': updatedAt!.toIso8601String()} : null,
    };
  }

  Program copyWith({
    String? id,
    String? name,
    String? description,
    String? code,
    String? adminId,
    bool? isPublic,
    List<Task>? tasks,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    List<String>? memberIds,
    List<String>? pendingRequests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Program(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      code: code ?? this.code,
      adminId: adminId ?? this.adminId,
      isPublic: isPublic ?? this.isPublic,
      tasks: tasks ?? this.tasks,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      memberIds: memberIds ?? this.memberIds,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
