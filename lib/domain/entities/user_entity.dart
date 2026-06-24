import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
  });

  /// Generates a short display name from email or displayName.
  String get shortName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!.split(' ').first;
    }
    return email.split('@').first;
  }

  @override
  List<Object?> get props => [uid, email, displayName];
}