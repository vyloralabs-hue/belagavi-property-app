import 'package:url_launcher/url_launcher.dart';

class GoogleMapsLauncher {
  GoogleMapsLauncher._();

  /// Zero-cost direct Google Maps navigation deep linking strategy
  static Future<bool> launchNavigation({
    required double latitude,
    required double longitude,
    String? query,
    String? locationTitle,
  }) async {
    final nativeUri = Uri.parse('google.navigation:q=$latitude,$longitude');
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');

    if (await canLaunchUrl(nativeUri)) {
      return await launchUrl(nativeUri);
    } else if (await canLaunchUrl(webUri)) {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Zero-cost direct Google Maps location pin view
  static Future<bool> launchLocationPin({
    required double latitude,
    required double longitude,
    String? query,
  }) async {
    final nativeUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude(${Uri.encodeComponent(query ?? "Property Location")})');
    final webUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    if (await canLaunchUrl(nativeUri)) {
      return await launchUrl(nativeUri);
    } else if (await canLaunchUrl(webUri)) {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
