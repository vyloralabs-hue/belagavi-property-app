import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../bootstrap/bootstrap.dart';
import '../../../core/security/user_role.dart';
import '../../../core/utils/local_storage.dart';

class AuthSessionStorageHelper {
  AuthSessionStorageHelper._();

  static const String _isLoggedInKey = 'belagavi_auth_is_logged_in';
  static const String _userRoleKey = 'belagavi_auth_user_role';
  static const String _mobileNumberKey = 'belagavi_auth_mobile_number';
  static const String _userNameKey = 'belagavi_auth_user_name';
  static const String _userEmailKey = 'belagavi_auth_user_email';
  static const String _userPhotoKey = 'belagavi_auth_user_photo';
  static const String _userUidKey = 'belagavi_auth_user_uid';
  static const String _providerIdKey = 'belagavi_auth_provider_id';
  static const String _biometricEnabledKey = 'belagavi_auth_biometric_enabled';
  static const String _biometricUnlockedKey = 'belagavi_auth_biometric_unlocked';

  static bool isBiometricEnabled() {
    try {
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        return storage.get(_biometricEnabledKey) == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        await storage.put(_biometricEnabledKey, enabled);
      }
    } catch (_) {}
  }

  static bool isBiometricUnlocked() {
    try {
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        return storage.get(_biometricUnlockedKey) == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setBiometricUnlocked(bool unlocked) async {
    try {
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        await storage.put(_biometricUnlockedKey, unlocked);
      }
    } catch (_) {}
  }

  static bool isLoggedIn() {
    try {
      if (Firebase.apps.isNotEmpty) {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser != null && !fbUser.isAnonymous && fbUser.uid.isNotEmpty) {
          return true;
        }
      }
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        final val = storage.get(_isLoggedInKey);
        final mobile = storage.get(_mobileNumberKey) as String?;
        final uid = storage.get(_userUidKey) as String?;
        // Anonymous/guest sessions are NEVER treated as authenticated
        if (mobile == 'guest' || (uid == null && (mobile == null || mobile.isEmpty))) {
          return false;
        }
        return val == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static bool isPublicVisitor() => !isLoggedIn();

  static String getUserRole() {
    try {
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        return storage.get(_userRoleKey) as String? ?? 'Buyer / Tenant';
      }
      return 'Buyer / Tenant';
    } catch (_) {
      return 'Buyer / Tenant';
    }
  }

  static UserRole getParsedUserRole() {
    return UserRoleExtension.fromString(getUserRole());
  }

  static String? getUserName() {
    try {
      if (Firebase.apps.isNotEmpty) {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser?.displayName != null && fbUser!.displayName!.isNotEmpty) {
          return fbUser.displayName;
        }
      }
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        return storage.get(_userNameKey) as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? getUserPhone() => getMobileNumber();

  static String? getMobileNumber() {
    try {
      if (Firebase.apps.isNotEmpty) {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser?.phoneNumber != null && fbUser!.phoneNumber!.isNotEmpty) {
          return fbUser.phoneNumber;
        }
      }
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        return storage.get(_mobileNumberKey) as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? getUserEmail() {
    try {
      if (Firebase.apps.isNotEmpty) {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser?.email != null && fbUser!.email!.isNotEmpty) {
          return fbUser.email;
        }
      }
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        return storage.get(_userEmailKey) as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? getUserPhoto() {
    try {
      if (Firebase.apps.isNotEmpty) {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser?.photoURL != null && fbUser!.photoURL!.isNotEmpty) {
          return fbUser.photoURL;
        }
      }
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        return storage.get(_userPhotoKey) as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? getUserUid() {
    try {
      if (Firebase.apps.isNotEmpty) {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser != null && !fbUser.isAnonymous && fbUser.uid.isNotEmpty) {
          return fbUser.uid;
        }
      }
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        final uid = storage.get(_userUidKey) as String?;
        if (uid != null && uid.isNotEmpty && uid != 'guest') {
          return uid;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static String getProviderId() {
    try {
      if (Firebase.apps.isNotEmpty) {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser?.providerData.isNotEmpty == true) {
          return fbUser!.providerData.first.providerId;
        }
      }
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        return storage.get(_providerIdKey) as String? ?? 'google.com';
      }
      return 'google.com';
    } catch (_) {
      return 'google.com';
    }
  }

  static Future<void> saveLoginSession({
    required String mobileNumber,
    String role = 'Buyer / Tenant',
    String? userName,
    String? userEmail,
    String? userPhoto,
    String? uid,
    String providerId = 'google.com',
  }) async {
    try {
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        await storage.put(_isLoggedInKey, true);
        await storage.put(_mobileNumberKey, mobileNumber);
        await storage.put(_userRoleKey, role);
        await storage.put(_providerIdKey, providerId);
        if (userName != null) await storage.put(_userNameKey, userName);
        if (userEmail != null) await storage.put(_userEmailKey, userEmail);
        if (userPhoto != null) await storage.put(_userPhotoKey, userPhoto);
        if (uid != null) await storage.put(_userUidKey, uid);
      }
    } catch (_) {}
  }

  static Future<void> setUserRole(String role) async {
    try {
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        await storage.put(_userRoleKey, role);
      }
    } catch (_) {}
  }

  static Future<void> logout() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseAuth.instance.signOut();
      }
      if (getIt.isRegistered<LocalStorage>()) {
        final storage = getIt<LocalStorage>();
        await storage.put(_isLoggedInKey, false);
        await storage.put(_mobileNumberKey, '');
        await storage.put(_userNameKey, '');
        await storage.put(_userEmailKey, '');
        await storage.put(_userPhotoKey, '');
        await storage.put(_userUidKey, '');
        await storage.put(_providerIdKey, '');
        await storage.put(_biometricUnlockedKey, false);
      }
    } catch (_) {}
  }
}
