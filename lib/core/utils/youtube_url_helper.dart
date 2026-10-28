/// Utility class for validating and parsing YouTube URLs and IDs across all supported formats:
/// - Standard watch: `https://www.youtube.com/watch?v=VIDEO_ID`
/// - Shortened: `https://youtu.be/VIDEO_ID`
/// - Shorts: `https://www.youtube.com/shorts/VIDEO_ID`
/// - Live stream: `https://www.youtube.com/live/VIDEO_ID`
/// - Embed: `https://www.youtube.com/embed/VIDEO_ID`
/// - Raw 11-character video ID
class YoutubeUrlHelper {
  static final RegExp _videoIdRegex = RegExp(r'^[a-zA-Z0-9_-]{11}$');

  static final List<RegExp> _urlPatterns = [
    // youtu.be/<id>
    RegExp(r'(?:youtu\.be\/)([a-zA-Z0-9_-]{11})', caseSensitive: false),
    // youtube.com/watch?v=<id>
    RegExp(r'(?:youtube\.com\/watch\?[^#]*\bv=)([a-zA-Z0-9_-]{11})', caseSensitive: false),
    // youtube.com/shorts/<id>
    RegExp(r'(?:youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})', caseSensitive: false),
    // youtube.com/live/<id>
    RegExp(r'(?:youtube\.com\/live\/)([a-zA-Z0-9_-]{11})', caseSensitive: false),
    // youtube.com/embed/<id>
    RegExp(r'(?:youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})', caseSensitive: false),
    // youtube.com/v/<id>
    RegExp(r'(?:youtube\.com\/v\/)([a-zA-Z0-9_-]{11})', caseSensitive: false),
  ];

  /// Extracts the canonical 11-character video ID from a YouTube URL or direct ID.
  /// Returns `null` if the input is empty or invalid.
  static String? extractVideoId(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Check if input is directly an 11-character ID
    if (_videoIdRegex.hasMatch(trimmed)) {
      return trimmed;
    }

    // Check against standard YouTube patterns
    for (final pattern in _urlPatterns) {
      final match = pattern.firstMatch(trimmed);
      if (match != null && match.groupCount >= 1) {
        final id = match.group(1);
        if (id != null && _videoIdRegex.hasMatch(id)) {
          return id;
        }
      }
    }

    return null;
  }

  /// Validates whether the given string is a valid YouTube URL or video ID.
  static bool isValid(String? input) => extractVideoId(input) != null;

  /// Returns canonical YouTube watch URL.
  static String buildWatchUrl(String videoId) => 'https://www.youtube.com/watch?v=$videoId';

  /// Returns canonical YouTube embed URL.
  static String buildEmbedUrl(String videoId) => 'https://www.youtube.com/embed/$videoId';

  /// Returns YouTube thumbnail URL.
  /// Falls back to hqdefault (480x360) which is guaranteed to exist for all uploaded YouTube videos.
  static String buildThumbnailUrl(String videoId, {bool highRes = false}) {
    final quality = highRes ? 'maxresdefault' : 'hqdefault';
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }
}
