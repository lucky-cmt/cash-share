import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

/// External browser and mailto launcher wrappers.
class UrlLauncherHelper {
  UrlLauncherHelper._();

  static Future<bool> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> openPrivacyAndTerms() {
    return openUrl(AppConstants.privacyPolicyUrl);
  }

  static Future<bool> sendSupportEmail(String email, {String? subject}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: subject != null ? {'subject': subject} : null,
    );
    return launchUrl(uri);
  }
}
