import '../utils/typedefs.dart';

/// Abstract AI Client interface for future AI integrations (e.g. Gemini, OpenAI, custom models)
abstract class AIClientInterface {
  /// Generate completion or response for a given text prompt
  FutureEither<String> generateText({
    required String prompt,
    Map<String, dynamic>? parameters,
  });

  /// Generate embeddings vector for semantic property search
  FutureEither<List<double>> generateEmbeddings({
    required String input,
  });
}
