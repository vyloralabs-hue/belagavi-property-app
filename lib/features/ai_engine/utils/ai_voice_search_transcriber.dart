class AIVoiceSearchTranscriber {
  AIVoiceSearchTranscriber._();

  /// Validates audio PCM stream length before submitting to STT engine
  static bool isValidAudioStream(List<int> audioBytes) {
    return audioBytes.isNotEmpty && audioBytes.length > 1024;
  }
}
