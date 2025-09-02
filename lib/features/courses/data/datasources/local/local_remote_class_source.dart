import 'package:f_clean_template/features/courses/data/datasources/i_remote_class_source.dart';

import '../../../domain/models/class_item.dart';

class LocalClassSource implements IClassSource {
  @override
  Future<List<ClassItem>> getClasses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      ClassItem(
        name: 'Programación Móvil',
        nrc: 5566,
        teacher: 'Augusto Salazar',
      ),
      ClassItem(
        name: 'Programación Móvil',
        nrc: 5566,
        teacher: 'Augusto Salazar',
      ),
    ];
  }
}
