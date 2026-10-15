import 'package:bikes_app/features/branches/domain/entities/branch.dart';

abstract final class BranchModel {
  static Branch fromJson(Map<String, dynamic> json) => Branch(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String?,
    isActive: json['is_active'] as bool? ?? true,
  );

  static Map<String, dynamic> toJson(BranchDraft draft) => {
    'name': draft.name,
    'address': draft.address,
    'is_active': draft.isActive,
  };
}
