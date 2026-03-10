import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _bestScoreKey = 'best_score';
  static const String _totalDeathsKey = 'total_deaths';

  static int _bestScore = 0;
  static int _totalDeaths = 0;

  static int get bestScore => _bestScore;
  static int get totalDeaths => _totalDeaths;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    _totalDeaths = prefs.getInt(_totalDeathsKey) ?? 0;
  }

  static Future<void> updateBestScore(int score) async {
    if (score > _bestScore) {
      _bestScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_bestScoreKey, _bestScore);
    }
  }

  static Future<void> incrementDeaths() async {
    _totalDeaths++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalDeathsKey, _totalDeaths);
  }

  static bool shouldShowAd(int deathsPerAd) {
    return _totalDeaths > 0 && _totalDeaths % deathsPerAd == 0;
  }
}
