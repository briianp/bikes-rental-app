import 'package:bikes_app/features/customers/domain/entities/customer.dart';

abstract final class CustomerModel {
  static Customer fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    phone: json['phone'] as String,
    documentId: json['document_id'] as String?,
    email: json['email'] as String?,
  );

  static Map<String, dynamic> toJson(NewCustomer customer) => {
    'full_name': customer.fullName,
    'phone': customer.phone,
    'document_id': customer.documentId,
    'email': customer.email,
  };
}
