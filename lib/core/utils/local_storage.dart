import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

@lazySingleton
class LocalStorage {
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isBoxOpen(AppConstants.userPrefsBoxName)) {
        await Hive.openBox(AppConstants.userPrefsBoxName);
      }
      AppLogger.i('LocalStorage (Hive) initialized successfully.');
    } catch (e) {
      AppLogger.e('Failed to initialize LocalStorage (Hive)', e);
    }
  }

  Box? get _userBox {
    try {
      if (Hive.isBoxOpen(AppConstants.userPrefsBoxName)) {
        return Hive.box(AppConstants.userPrefsBoxName);
      }
    } catch (e) {
      AppLogger.w('Hive box access warning: $e');
    }
    return null;
  }

  Future<void> put(String key, dynamic value) async {
    try {
      final box = _userBox;
      if (box != null) {
        await box.put(key, value);
      }
    } catch (e) {
      AppLogger.w('LocalStorage put failed for key $key: $e');
    }
  }

  dynamic get(String key, {dynamic defaultValue}) {
    try {
      final box = _userBox;
      if (box != null) {
        return box.get(key, defaultValue: defaultValue);
      }
    } catch (e) {
      AppLogger.w('LocalStorage get failed for key $key: $e');
    }
    return defaultValue;
  }

  Future<void> delete(String key) async {
    try {
      final box = _userBox;
      if (box != null) {
        await box.delete(key);
      }
    } catch (e) {
      AppLogger.w('LocalStorage delete failed for key $key: $e');
    }
  }

  Future<void> clear() async {
    try {
      final box = _userBox;
      if (box != null) {
        await box.clear();
      }
    } catch (e) {
      AppLogger.w('LocalStorage clear failed: $e');
    }
  }
}
