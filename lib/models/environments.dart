import 'package:hive_flutter/hive_flutter.dart';
import 'package:ibm_apic_dt/models/environment.dart';

part 'environments.g.dart';

@HiveType(typeId: 1)
class Environments extends HiveObject {
  @HiveField(0)
  final List<Environment> _environments;

  List<Environment> get environments => _environments;

  Environments(this._environments);
}
