import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'unreal_engine_info.dart';

class EngineUpdateService {
  static const String _releaseNotesUrl = 'https://www.unrealengine.com/en-US/release-notes';

  Future<String?> fetchLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(_releaseNotesUrl)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Find all matches for "Unreal Engine X.Y(.Z)"
        final regExp = RegExp(r'Unreal Engine (\d+\.\d+(?:\.\d+)?)');
        final matches = regExp.allMatches(response.body);

        if (matches.isNotEmpty) {
          // Extract version strings
          List<String> versions = matches.map((m) => m.group(1)!).toList();

          // Sort versions descending using the common comparison logic
          versions.sort((a, b) => UnrealEngineInfo.compareVersions(b, a));

          return versions.first;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch latest UE version: $e');
      }
    }

    return null;
  }
}
