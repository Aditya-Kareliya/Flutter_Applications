import 'dart:convert';
import 'package:flutter/services.dart';

import 'models/gita_shloka_model.dart';

class GitaService {
  static Future<List<GitaShloka>> loadShlokas() async {
    final String jsonString = await rootBundle.loadString('assets/data/gita_shlokas.json');

    final List data = json.decode(jsonString);

    return data.map((e) => GitaShloka.fromJson(e)).toList();
  }
}
