class EvaluationRepository {
  final List<Map<String, dynamic>> _storage = [];

  Future<void> saveEvaluation(Map<String, dynamic> evaluation) async {
    _storage.add(evaluation);
  }

  Future<List<Map<String, dynamic>>> getEvaluationsByActivity(String activityId) async {
    return _storage.where((e) => e['activityId'] == activityId).toList();
  }

  Future<List<Map<String, dynamic>>> getEvaluationsByEvaluator(String evaluatorId) async {
    return _storage.where((e) => e['evaluatorId'] == evaluatorId).toList();
  }

  Future<void> clearAll() async {
    _storage.clear();
  }
}
