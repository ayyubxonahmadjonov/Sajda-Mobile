import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String nameAr;

  @HiveField(2)
  String nameUz;

  @HiveField(3)
  int suraIndex;

  @HiveField(4)
  int ayatIndex;

  User({
    required this.id,
    required this.nameAr,
    required this.nameUz,
    required this.suraIndex,
    required this.ayatIndex,
  });
}