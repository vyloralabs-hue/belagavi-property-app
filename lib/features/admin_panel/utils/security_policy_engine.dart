import '../domain/entities/admin_entities.dart';

class SecurityPolicyEngine {
  SecurityPolicyEngine._();

  /// Evaluates threat severity and returns action directive
  static String evaluateAction(SecurityThreatLogEntity threat) {
    return switch (threat.severity) {
      ThreatSeverity.low => 'Log & monitor IP',
      ThreatSeverity.medium => 'Trigger CAPTCHA challenge',
      ThreatSeverity.high => 'Temporary 1-hour IP lock',
      ThreatSeverity.critical => 'Permanent IP block & Admin alert',
    };
  }
}
