import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    super.firebaseUid,
    required super.fullName,
    required super.phoneNumber,
    super.email,
    super.role = UserRoleEnum.buyer,
    super.avatarUrl,
    super.companyName,
    super.reraNumber,
    super.kycStatus = KYCStatus.unverified,
    super.teamId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      firebaseUid: json['firebase_uid'] as String?,
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      email: json['email'] as String?,
      role: UserRoleEnum.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRoleEnum.buyer,
      ),
      avatarUrl: json['avatar_url'] as String?,
      companyName: json['company_name'] as String?,
      reraNumber: json['rera_number'] as String?,
      kycStatus: KYCStatus.values.firstWhere(
        (e) => e.name == json['kyc_status'],
        orElse: () => KYCStatus.unverified,
      ),
      teamId: json['team_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        if (firebaseUid != null) 'firebase_uid': firebaseUid,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'role': role.name,
        'avatar_url': avatarUrl,
        'company_name': companyName,
        'rera_number': reraNumber,
        'kyc_status': kycStatus.name,
        'team_id': teamId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class KYCVerificationModel extends KYCVerificationEntity {
  const KYCVerificationModel({
    required super.id,
    required super.userId,
    super.status = KYCStatus.unverified,
    super.documentType,
    super.documentNumber,
    super.documentUrl,
    super.rejectionReason,
    super.verifiedAt,
  });

  factory KYCVerificationModel.fromJson(Map<String, dynamic> json) {
    return KYCVerificationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      status: KYCStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => KYCStatus.unverified,
      ),
      documentType: json['document_type'] as String?,
      documentNumber: json['document_number'] as String?,
      documentUrl: json['document_url'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'status': status.name,
        'document_type': documentType,
        'document_number': documentNumber,
        'document_url': documentUrl,
        'rejection_reason': rejectionReason,
        'verified_at': verifiedAt?.toIso8601String(),
      };
}
