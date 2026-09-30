import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/services/isbn_lookup_service.dart';

void main() {
  group('IsbnLookupService.normalize', () {
    test('accepts ISBN-13 with or without dashes', () {
      expect(IsbnLookupService.normalize('9781476753836'), '9781476753836');
      expect(IsbnLookupService.normalize('978-1-4767-5383-6'), '9781476753836');
      expect(IsbnLookupService.normalize(' 978 1 4767 5383 6 '), '9781476753836');
    });

    test('converts ISBN-10 (including X check digit) to ISBN-13', () {
      expect(IsbnLookupService.normalize('1476753830'), '9781476753836');
      expect(IsbnLookupService.normalize('0-8044-2957-X'), '9780804429573');
    });

    test('rejects bad checksums and grocery barcodes', () {
      expect(IsbnLookupService.normalize('9781476753837'), isNull);
      expect(IsbnLookupService.normalize('1476753831'), isNull);
      // A valid EAN-13 that isn't Bookland (978/979) is a product, not a book.
      expect(IsbnLookupService.normalize('5000112637922'), isNull);
      expect(IsbnLookupService.normalize('hello'), isNull);
    });

    test('round-trips to ISBN-10', () {
      expect(IsbnLookupService.toIsbn10('9780804429573'), '080442957X');
      expect(IsbnLookupService.toIsbn10('9791234567896'), isNull);
    });
  });

  group('cookbook description', () {
    test('stores the ISBN so a re-scan finds the same book', () {
      const book = BookInfo(
        isbn13: '9781476753836',
        title: 'Salt, Fat, Acid, Heat',
        authors: ['Samin Nosrat'],
        publisher: 'Simon & Schuster',
        year: '2017',
      );
      final description = book.cookbookDescription;
      expect(description, contains('By Samin Nosrat'));
      expect(description, contains('Simon & Schuster · 2017'));
      expect(IsbnLookupService.isbnFromDescription(description), '9781476753836');
      expect(IsbnLookupService.isbnFromDescription('Just my notes'), isNull);
    });
  });
}
