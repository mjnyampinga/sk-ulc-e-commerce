import 'package:hive/hive.dart';

part 'write_action.g.dart';

@HiveType(typeId: 10)
class WriteAction extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String type; // e.g., 'order', 'profile_update'
  @HiveField(2)
  final Map<String, dynamic> data;

  WriteAction({required this.id, required this.type, required this.data});
}
