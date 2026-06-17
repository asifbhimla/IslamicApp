import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiEdition {
  const ApiEdition({
    required this.identifier,
    required this.language,
    required this.englishName,
    required this.name,
  });

  final String identifier;
  final String language;
  final String englishName;
  final String name;

  factory ApiEdition.fromJson(Map<String, dynamic> json) {
    return ApiEdition(
      identifier: json['identifier'] as String,
      language: json['language'] as String,
      englishName: json['englishName'] as String,
      name: json['name'] as String,
    );
  }
}

class ApiVerse {
  const ApiVerse({required this.arabic, required this.translation});

  final String arabic;
  final String translation;
}

class AlQuranCloudService {
  static const _baseUrl = 'https://api.alquran.cloud/v1';
  static const _timeout = Duration(seconds: 10);

  static List<ApiEdition>? _cachedEditions;
  static final Map<String, String> _verseCache = {};

  static Future<List<ApiEdition>?> fetchEditions() async {
    if (_cachedEditions != null) return _cachedEditions;
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/edition?type=translation'))
          .timeout(_timeout);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (data['data'] as List)
          .map((e) => ApiEdition.fromJson(e as Map<String, dynamic>))
          .toList();
      _cachedEditions = list;
      return list;
    } catch (_) {
      return null;
    }
  }

  static Future<ApiVerse?> fetchVerse(
      int surah, int verse, String edition) async {
    final cacheKey = '$surah:$verse';
    final cachedArabic = _verseCache['$cacheKey:quran-uthmani'];
    final cachedTrans = _verseCache['$cacheKey:$edition'];
    if (cachedArabic != null && cachedTrans != null) {
      return ApiVerse(arabic: cachedArabic, translation: cachedTrans);
    }

    try {
      final url = '$_baseUrl/ayah/$surah:$verse/editions/quran-uthmani,$edition';
      final response =
          await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final editions = data['data'] as List;
      final arabic = (editions[0] as Map<String, dynamic>)['text'] as String;
      final translation =
          (editions[1] as Map<String, dynamic>)['text'] as String;
      _verseCache['$cacheKey:quran-uthmani'] = arabic;
      _verseCache['$cacheKey:$edition'] = translation;
      return ApiVerse(arabic: arabic, translation: translation);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> fetchVerseTranslation(
      int surah, int verse, String edition) async {
    final cacheKey = '$surah:$verse:$edition';
    final cached = _verseCache[cacheKey];
    if (cached != null) return cached;

    try {
      final url = '$_baseUrl/ayah/$surah:$verse/$edition';
      final response =
          await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = (data['data'] as Map<String, dynamic>)['text'] as String;
      _verseCache[cacheKey] = text;
      return text;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<int, ApiVerse>?> fetchSurah(
      int surahNumber, String edition) async {
    try {
      final url =
          '$_baseUrl/surah/$surahNumber/editions/quran-uthmani,$edition';
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final editions = data['data'] as List;
      final arabicAyahs =
          (editions[0] as Map<String, dynamic>)['ayahs'] as List;
      final transAyahs =
          (editions[1] as Map<String, dynamic>)['ayahs'] as List;

      final result = <int, ApiVerse>{};
      for (var i = 0; i < arabicAyahs.length; i++) {
        final verseNum =
            (arabicAyahs[i] as Map<String, dynamic>)['numberInSurah'] as int;
        final arabic =
            (arabicAyahs[i] as Map<String, dynamic>)['text'] as String;
        final trans =
            (transAyahs[i] as Map<String, dynamic>)['text'] as String;

        result[verseNum] = ApiVerse(arabic: arabic, translation: trans);
        _verseCache['$surahNumber:$verseNum:quran-uthmani'] = arabic;
        _verseCache['$surahNumber:$verseNum:$edition'] = trans;
      }
      return result;
    } catch (_) {
      return null;
    }
  }
}
