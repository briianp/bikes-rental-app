import 'package:bikes_app/features/auth/domain/entities/app_user.dart';

/// Modelo de un registro de `profiles` (con `branches(name)` embebido).
class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
    this.branchId,
    this.branchName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final branch = json['branches'] as Map<String, dynamic>?;
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      // 'admin' → UserRole.admin
      role: UserRole.values.byName(json['role'] as String),
      isActive: json['is_active'] as bool? ?? true,
      branchId: json['branch_id'] as String?,
      branchName: branch?['name'] as String?,
    );
  }

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final bool isActive;
  final String? branchId;
  final String? branchName;

  AppUser toEntity() => AppUser(
    id: id,
    name: fullName,
    email: email,
    role: role,
    isActive: isActive,
    branchId: branchId,
    branchName: branchName,
  );
}
