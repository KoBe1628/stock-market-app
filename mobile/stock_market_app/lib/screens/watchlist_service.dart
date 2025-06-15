import 'package:shared_preferences/shared_preferences.dart';

class WatchlistService {
  static const _key = 'watchlist';

  static Future<List<String>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addToWatchlist(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (!list.contains(symbol)) {
      list.add(symbol);
      await prefs.setStringList(_key, list);
    }
  }

  static Future<void> removeFromWatchlist(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(symbol);
    await prefs.setStringList(_key, list);
  }

  static Future<bool> isInWatchlist(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.contains(symbol);
  }
}
