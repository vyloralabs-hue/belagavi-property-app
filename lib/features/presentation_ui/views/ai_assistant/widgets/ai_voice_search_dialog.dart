import 'package:flutter/material.dart';
import '../../../theme/app_design_system.dart';

class AIVoiceSearchDialog extends StatefulWidget {
  final Function(String transcribedText) onSpeechRecognized;

  const AIVoiceSearchDialog({super.key, required this.onSpeechRecognized});

  @override
  State<AIVoiceSearchDialog> createState() => _AIVoiceSearchDialogState();
}

class _AIVoiceSearchDialogState extends State<AIVoiceSearchDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String _transcription = 'Listening for voice search...';
  bool _isListening = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _simulateSpeechRecognition();
  }

  Future<void> _simulateSpeechRecognition() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() {
        _transcription = '3 BHK Flat in Tilakwadi under 65 Lakhs';
        _isListening = false;
      });
      _pulseController.stop();
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        widget.onSpeechRecognized(_transcription);
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween<double>(
                begin: 0.9,
                end: 1.15,
              ).animate(_pulseController),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _isListening
                      ? AppDesignSystem.accentEmerald
                      : AppDesignSystem.primaryNavy,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.check,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isListening ? 'Speak Now...' : 'Recognized Speech',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: AppDesignSystem.borderRadiusM,
              ),
              child: Text(
                _transcription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
