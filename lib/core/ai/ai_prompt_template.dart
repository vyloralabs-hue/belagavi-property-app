class AIPromptTemplate {
  final String template;
  final List<String> requiredVariables;

  const AIPromptTemplate({
    required this.template,
    required this.requiredVariables,
  });

  String format(Map<String, String> values) {
    String formatted = template;
    for (final key in requiredVariables) {
      final value = values[key] ?? '';
      formatted = formatted.replaceAll('{$key}', value);
    }
    return formatted;
  }
}
