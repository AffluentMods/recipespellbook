import 'dart:convert';

import 'package:http/http.dart' as http;

/// Metadata for a printed book, resolved from its ISBN.
class BookInfo {
  final String isbn13;
  final String title;
  final String? subtitle;
  final List<String> authors;
  final String? publisher;
  final String? year;
  final int? pageCount;
  final String? coverUrl;

  const BookInfo({
    required this.isbn13,
    required this.title,
    this.subtitle,
    this.authors = const [],
    this.publisher,
    this.year,
    this.pageCount,
    this.coverUrl,
  });

  String get authorLine => authors.join(', ');

  /// The cookbook description we store: who wrote it, who published it, and
  /// the ISBN (which is also how we recognise a book that's already been added).
  String get cookbookDescription {
    final lines = <String>[];
    if (authors.isNotEmpty) lines.add('By $authorLine');
    final pub = [
      if (publisher != null && publisher!.isNotEmpty) publisher!,
      if (year != null && year!.isNotEmpty) year!,
    ].join(' · ');
    if (pub.isNotEmpty) lines.add(pub);
    lines.add('${IsbnLookupService.isbnTag} $isbn13');
    return lines.join('\n');
  }
}

/// Looks up printed books (cookbooks) by ISBN. Open Library first — free, no
/// key, good cover coverage — then Google Books as a fallback for titles Open
/// Library doesn't know.
class IsbnLookupService {
  static const isbnTag = 'ISBN';

  static const Map<String, String> _headers = {
    'User-Agent': 'RecipeSpellbook/1.6 (support@recipespellbook.app)',
  };

  /// Strips spaces/dashes and validates an ISBN-10 or ISBN-13 checksum.
  /// Returns the ISBN-13 form, or null if [raw] isn't a valid ISBN.
  static String? normalize(String raw) {
    final s = raw.toUpperCase().replaceAll(RegExp(r'[^0-9X]'), '');
    if (s.length == 13 && RegExp(r'^\d{13}$').hasMatch(s)) {
      if (!(s.startsWith('978') || s.startsWith('979'))) return null;
      return _isbn13Valid(s) ? s : null;
    }
    if (s.length == 10 && RegExp(r'^\d{9}[\dX]$').hasMatch(s)) {
      if (!_isbn10Valid(s)) return null;
      final core = '978${s.substring(0, 9)}';
      return '$core${_isbn13CheckDigit(core)}';
    }
    return null;
  }

  /// True for barcodes that are books (Bookland EAN-13) rather than groceries.
  static bool looksLikeIsbn(String raw) => normalize(raw) != null;

  static bool _isbn13Valid(String s) =>
      _isbn13CheckDigit(s.substring(0, 12)) == s[12];

  static String _isbn13CheckDigit(String first12) {
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(first12[i]) * (i.isEven ? 1 : 3);
    }
    return ((10 - sum % 10) % 10).toString();
  }

  static bool _isbn10Valid(String s) {
    var sum = 0;
    for (var i = 0; i < 10; i++) {
      final v = s[i] == 'X' ? 10 : int.parse(s[i]);
      sum += v * (10 - i);
    }
    return sum % 11 == 0;
  }

  /// ISBN-10 form of a 978-prefixed ISBN-13 (older catalogues only index that).
  static String? toIsbn10(String isbn13) {
    if (!isbn13.startsWith('978')) return null;
    final core = isbn13.substring(3, 12);
    var sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += int.parse(core[i]) * (10 - i);
    }
    final check = (11 - sum % 11) % 11;
    return '$core${check == 10 ? 'X' : check}';
  }

  /// Resolve [isbn] (any form). Returns null when no catalogue knows the book.
  /// Throws only on invalid input; network failures fall through to null.
  static Future<BookInfo?> lookup(String isbn) async {
    final isbn13 = normalize(isbn);
    if (isbn13 == null) throw const FormatException('Invalid ISBN');
    return await _openLibrary(isbn13) ?? await _googleBooks(isbn13);
  }

  static Future<BookInfo?> _openLibrary(String isbn13) async {
    try {
      final uri = Uri.parse(
          'https://openlibrary.org/api/books?bibkeys=ISBN:$isbn13&format=json&jscmd=data');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = body['ISBN:$isbn13'] as Map<String, dynamic>?;
      if (data == null) return null;
      final title = (data['title'] as String?)?.trim();
      if (title == null || title.isEmpty) return null;

      final authors = ((data['authors'] as List?) ?? const [])
          .map((a) => (a as Map)['name']?.toString().trim() ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      final publishers = ((data['publishers'] as List?) ?? const [])
          .map((p) => (p as Map)['name']?.toString().trim() ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      final cover = data['cover'] as Map<String, dynamic>?;
      final coverUrl = (cover?['large'] ?? cover?['medium']) as String?;

      return BookInfo(
        isbn13: isbn13,
        title: title,
        subtitle: (data['subtitle'] as String?)?.trim(),
        authors: authors,
        publisher: publishers.isEmpty ? null : publishers.first,
        year: _year(data['publish_date']?.toString()),
        pageCount: data['number_of_pages'] as int?,
        coverUrl: _https(coverUrl),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<BookInfo?> _googleBooks(String isbn13) async {
    try {
      final uri = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn13');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final items = body['items'] as List?;
      if (items == null || items.isEmpty) return null;
      final info = (items.first as Map)['volumeInfo'] as Map<String, dynamic>?;
      if (info == null) return null;
      final title = (info['title'] as String?)?.trim();
      if (title == null || title.isEmpty) return null;

      final links = info['imageLinks'] as Map<String, dynamic>?;
      var coverUrl = (links?['thumbnail'] ?? links?['smallThumbnail']) as String?;
      // Google serves a tiny thumbnail by default; zoom=0 asks for the largest
      // edition it has, and dropping the curled-page effect looks cleaner.
      coverUrl = coverUrl?.replaceAll('&edge=curl', '').replaceAll('zoom=1', 'zoom=0');

      return BookInfo(
        isbn13: isbn13,
        title: title,
        subtitle: (info['subtitle'] as String?)?.trim(),
        authors: ((info['authors'] as List?) ?? const []).map((a) => a.toString()).toList(),
        publisher: info['publisher'] as String?,
        year: _year(info['publishedDate'] as String?),
        pageCount: info['pageCount'] as int?,
        coverUrl: _https(coverUrl),
      );
    } catch (_) {
      return null;
    }
  }

  static String? _year(String? date) =>
      date == null ? null : RegExp(r'(1[5-9]|20)\d{2}').firstMatch(date)?.group(0);

  static String? _https(String? url) =>
      url?.replaceFirst(RegExp(r'^http://'), 'https://');

  /// Extracts the stored ISBN-13 from a cookbook description written by
  /// [BookInfo.cookbookDescription], so a re-scan finds the existing book.
  static String? isbnFromDescription(String? description) {
    if (description == null) return null;
    final m = RegExp('$isbnTag (97[89]\\d{10})').firstMatch(description);
    return m?.group(1);
  }
}
