import 'package:f_clean_template/features/product/domain/models/class_item.dart';

abstract class IClassSource {
  Future<List<ClassItem>> getClasses();
}
