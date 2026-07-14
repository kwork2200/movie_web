import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/error/exceptions.dart';
import '../models/watchlist_item_model.dart';

abstract class WatchlistLocalDataSource {
  Future<List<WatchlistItemModel>> getWatchListItems();
  Future<int> addWatchListItem(WatchlistItemModel item);
  Future<void> removeWatchListItem(int index);
  Future<int> isBookmarked(int tmdbID);
}

class WatchlistLocalDataSourceImpl extends WatchlistLocalDataSource {
  final Box<WatchlistItemModel>? _box;
  final SharedPreferences? _prefs;
  static const String _watchlistKey = 'watchlist_items';

  WatchlistLocalDataSourceImpl(this._box) : _prefs = null;

  WatchlistLocalDataSourceImpl.web(this._prefs) : _box = null;

  @override
  Future<List<WatchlistItemModel>> getWatchListItems() async {
    try {
      if (kIsWeb && _prefs != null) {
        final String? watchlistJson = _prefs!.getString(_watchlistKey);
        if (watchlistJson != null) {
          final List<dynamic> decoded = json.decode(watchlistJson);
          return decoded.map((item) => WatchlistItemModel.fromJson(item)).toList();
        }
        return [];
      }
      return _box!.values.toList();
    } catch (e) {
      throw DatabaseException(errorMessage: e.toString());
    }
  }

  @override
  Future<int> addWatchListItem(WatchlistItemModel item) async {
    try {
      if (kIsWeb && _prefs != null) {
        final currentItems = await getWatchListItems();
        currentItems.add(item);
        final String encoded = json.encode(currentItems.map((e) => e.toJson()).toList());
        await _prefs!.setString(_watchlistKey, encoded);
        return currentItems.length - 1;
      }
      return await _box!.add(item);
    } catch (e) {
      throw DatabaseException(errorMessage: e.toString());
    }
  }

  @override
  Future<void> removeWatchListItem(int index) async {
    try {
      if (kIsWeb && _prefs != null) {
        final currentItems = await getWatchListItems();
        if (index >= 0 && index < currentItems.length) {
          currentItems.removeAt(index);
          final String encoded = json.encode(currentItems.map((e) => e.toJson()).toList());
          await _prefs!.setString(_watchlistKey, encoded);
        }
      } else {
        await _box!.deleteAt(index);
      }
    } catch (e) {
      throw DatabaseException(errorMessage: e.toString());
    }
  }

  @override
  Future<int> isBookmarked(int tmdbID) async {
    try {
      if (kIsWeb && _prefs != null) {
        final models = await getWatchListItems();
        return models.indexWhere((model) => model.tmdbID == tmdbID);
      }
      final models = _box!.values.toList();
      return models.indexWhere((model) => model.tmdbID == tmdbID);
    } catch (e) {
      throw DatabaseException(errorMessage: e.toString());
    }
  }
}
