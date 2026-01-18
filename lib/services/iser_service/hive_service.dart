import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sajda_app/models/isar_sura/user.dart';

class HiveService {
  static const String _boxName = 'usersBox';

  // Singleton pattern
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Box<User>? _userBox;

  // Hive ni ishga tushirish
  Future<void> init() async {
    if (_userBox != null) return; // Agar allaqachon init bo'lsa, qaytish

    await Hive.initFlutter();

    // User modelini registratsiya qilish
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }

    // Box ochish
    _userBox = await Hive.openBox<User>(_boxName);
  }

  // Box ni olish (har safar tekshirish)
  Box<User> get _box {
    if (_userBox == null) {
      throw Exception('HiveService ishga tushirilmagan! init() ni chaqiring.');
    }
    return _userBox!;
  }

  // Sura saqlash
  Future<void> saveSura(User user) async {
    await _box.put(user.id, user);
  }

  // Barcha suralarni olish
  Future<List<User>> getAllSura() async {
    return _box.values.toList();
  }

  // ID bo'yicha sura olish
  Future<User?> getSuraWithId(int id) async {
    return _box.get(id);
  }

  // Surani o'chirish
  Future<bool> removeSura(int id) async {
    await _box.delete(id);
    return true;
  }

  // Barcha ID larni olish
  List<int> getAllIds() {
    return _box.keys.cast<int>().toList();
  }

  // Barcha ma'lumotlarni tozalash
  Future<void> clearAll() async {
    await _box.clear();
  }

  // Box yopish
  Future<void> close() async {
    await _box.close();
    _userBox = null;
  }
}