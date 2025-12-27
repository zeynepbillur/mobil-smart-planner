class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? programIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.programIds,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // id, _id veya id field'ından alınabilir
    String userId;
    if (json.containsKey('id') && json['id'] != null) {
      userId = json['id'].toString();
    } else if (json.containsKey('_id')) {
      userId = json['_id'] is Map ? json['_id']['\$oid'] : json['_id'].toString();
    } else {
      throw Exception('User id bulunamadı');
    }

    return User(
      id: userId,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      avatarUrl: json['avatarUrl']?.toString(),
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
      programIds: json['programIds'] != null
          ? List<String>.from(json['programIds'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': {'\$oid': id},
      'name': name,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt != null ? {'\$date': createdAt!.toIso8601String()} : null,
      'updatedAt': updatedAt != null ? {'\$date': updatedAt!.toIso8601String()} : null,
      'programIds': programIds,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? programIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      programIds: programIds ?? this.programIds,
    );
  }
}
