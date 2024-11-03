import 'package:cloud_firestore/cloud_firestore.dart';

class HobbyModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final DateTime registeredDate;
  final DateTime? updatedAt;

  HobbyModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.registeredDate,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'registeredDate': Timestamp.fromDate(registeredDate),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory HobbyModel.fromMap(Map<String, dynamic> map) {
    return HobbyModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      registeredDate: (map['registeredDate'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Criar uma cópia do hobby com alterações
  HobbyModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    DateTime? registeredDate,
    DateTime? updatedAt,
  }) {
    return HobbyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      registeredDate: registeredDate ?? this.registeredDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Para comparação de objetos
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HobbyModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              userId == other.userId &&
              name == other.name &&
              description == other.description &&
              registeredDate == other.registeredDate;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      description.hashCode ^
      registeredDate.hashCode;
}