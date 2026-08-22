/// Represents a row from the public.profiles table.
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.status,
    this.phone,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String role;   // 'passenger' | 'driver' | 'admin'
  final String status; // 'active' | 'pending' | 'suspended'
  final String? phone;
  final String? avatarUrl;

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id:        map['id']         as String,
      fullName:  map['full_name']  as String? ?? '',
      role:      map['role']       as String? ?? 'passenger',
      status:    map['status']     as String? ?? 'active',
      phone:     map['phone']      as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':         id,
    'full_name':  fullName,
    'role':       role,
    'status':     status,
    'phone':      phone,
    'avatar_url': avatarUrl,
  };

  ProfileModel copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? status,
  }) {
    return ProfileModel(
      id:        id,
      fullName:  fullName  ?? this.fullName,
      role:      role,
      status:    status    ?? this.status,
      phone:     phone     ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() =>
      'ProfileModel(id: $id, name: $fullName, role: $role, status: $status)';
}
