class GitaShloka {
  final String chapter;
  final String verse;
  final String shloka;
  final String transliteration;
  final String meaning;

  const GitaShloka({required this.chapter, required this.verse, required this.shloka, required this.transliteration, required this.meaning});

  factory GitaShloka.fromJson(Map<String, dynamic> json) {
    return GitaShloka(
      chapter: json['chapter_number'].toString(),
      verse: json['verse_number'].toString(),
      shloka: json['text'] ?? "",
      transliteration: json['transliteration'] ?? "",
      meaning: json['word_meanings'] ?? "",
    );
  }
}
