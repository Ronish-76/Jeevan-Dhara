import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.additionalData,
  });

  final String id;
  final String email;
  final String name;
  final String role;
  final Map<String, dynamic>? additionalData;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'patient',
      additionalData: data['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      if (additionalData != null) 'additionalData': additionalData,
    };
  }
}
