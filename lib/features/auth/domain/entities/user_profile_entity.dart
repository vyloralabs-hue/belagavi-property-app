import 'package:equatable/equatable.dart';

enum UserRoleEnum {
  buyer,
  seller,
  broker,
  builder,
  brokerTeamMember,
  builderTeamMember,
  admin,
  superAdmin,
}

enum KYCStatus { unverified, pendingKyc, verified, suspended }

class KYCVerificationEntity extends Equatable {
  final String id;
  final String userId;
  final KYCStatus status;
  final String? documentType; // 'aadhaar', 'pan', 'rera_license', 'cin'
  final String? documentNumber;
  final String? documentUrl;
  final String? rejectionReason;
  final DateTime? verifiedAt;

  const KYCVerificationEntity({
    required this.id,
    required this.userId,
    this.status = KYCStatus.unverified,
    this.documentType,
    this.documentNumber,
    this.documentUrl,
    this.rejectionReason,
    this.verifiedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        status,
        documentType,
        documentNumber,
        documentUrl,
        rejectionReason,
        verifiedAt,
      ];
}

class UserProfileEntity extends Equatable {
  final String id; // Maps internal profiles.id UUID
  final String? firebaseUid; // Maps Firebase Auth UID
  final String fullName;
  final String phoneNumber;
  final String? email;
  final UserRoleEnum role;
  final String? avatarUrl;
  final String? companyName;
  final String? reraNumber;
  final KYCStatus kycStatus;
  final String? teamId; // Belongs to Broker or Builder team
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileEntity({
    required this.id,
    this.firebaseUid,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.role = UserRoleEnum.buyer,
    this.avatarUrl,
    this.companyName,
    this.reraNumber,
    this.kycStatus = KYCStatus.unverified,
    this.teamId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isVerified => kycStatus == KYCStatus.verified;
  bool get isBrokerOrBuilder => role == UserRoleEnum.broker || role == UserRoleEnum.builder;
  bool get isAdminOrSuperAdmin => role == UserRoleEnum.admin || role == UserRoleEnum.superAdmin;

  @override
  List<Object?> get props => [
        id,
        firebaseUid,
        fullName,
        phoneNumber,
        email,
        role,
        avatarUrl,
        companyName,
        reraNumber,
        kycStatus,
        teamId,
        createdAt,
        updatedAt,
      ];
}
