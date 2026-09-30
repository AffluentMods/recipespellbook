import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/utils/invite_link_parser.dart';

InviteTarget? _uri(String s) => InviteLinkParser.parseUri(Uri.parse(s));
InviteTarget? _text(String s) => InviteLinkParser.parseText(s);

void main() {
  group('parseUri — share links', () {
    test('universal link /s/<code>', () {
      expect(_uri('https://recipespellbook.app/s/aB3_-x'),
          const InviteTarget.shareCode('aB3_-x'));
    });

    test('www / sub-domain and query string are tolerated', () {
      expect(_uri('https://www.recipespellbook.app/s/abc123?utm_source=x'),
          const InviteTarget.shareCode('abc123'));
    });

    test('links copied from the web app under /app/', () {
      expect(_uri('https://recipespellbook.app/app/s/abc123'),
          const InviteTarget.shareCode('abc123'));
    });

    test('custom scheme recipespellbook://s/<code>', () {
      expect(_uri('recipespellbook://s/abc123'), const InviteTarget.shareCode('abc123'));
    });

    test('host-less custom scheme recipespellbook:///s/<code>', () {
      expect(_uri('recipespellbook:///s/abc123'), const InviteTarget.shareCode('abc123'));
    });

    test('web "Open in App" recipespellbook://import?code=<code>', () {
      expect(_uri('recipespellbook://import?code=abc123'),
          const InviteTarget.shareCode('abc123'));
    });

    test('?code= is ignored on other hosts (Kroger OAuth callback)', () {
      expect(_uri('recipespellbook://kroger-callback?code=abc123'), isNull);
      expect(_uri('https://recipespellbook.app/?code=abc123'), isNull);
      expect(_uri('https://recipespellbook.app/kroger-callback?code=abc123'), isNull);
    });

    test('route is /s/<code>', () {
      expect(_uri('https://recipespellbook.app/s/abc123')!.route, '/s/abc123');
    });
  });

  group('parseUri — community links', () {
    test('recipespellbook://community?id=<id>', () {
      expect(_uri('recipespellbook://community?id=clx9abc'),
          const InviteTarget.communityId('clx9abc'));
    });

    test('recipespellbook://community/<id>', () {
      expect(_uri('recipespellbook://community/clx9abc'),
          const InviteTarget.communityId('clx9abc'));
    });

    test('https://recipespellbook.app/community/<id>', () {
      final t = _uri('https://recipespellbook.app/community/clx9abc');
      expect(t, const InviteTarget.communityId('clx9abc'));
      expect(t!.route, '/community/clx9abc');
    });

    test('app pages under /community are not ids', () {
      expect(_uri('https://recipespellbook.app/community/publish'), isNull);
      expect(_uri('https://recipespellbook.app/community'), isNull);
    });
  });

  group('parseUri — family invites', () {
    test('https://recipespellbook.app/family/join/<code>', () {
      final t = _uri('https://recipespellbook.app/family/join/A1B2C3D4');
      expect(t, const InviteTarget.familyInviteCode('A1B2C3D4'));
      expect(t!.route, '/family/join/A1B2C3D4');
    });

    test('recipespellbook://family/join/<code>', () {
      expect(_uri('recipespellbook://family/join/A1B2C3D4'),
          const InviteTarget.familyInviteCode('A1B2C3D4'));
    });

    test('recipespellbook://family?code=<code>', () {
      expect(_uri('recipespellbook://family?code=A1B2C3D4'),
          const InviteTarget.familyInviteCode('A1B2C3D4'));
    });

    test('/family without join/<code> is not an invite', () {
      expect(_uri('https://recipespellbook.app/family'), isNull);
      expect(_uri('https://recipespellbook.app/family/join'), isNull);
    });
  });

  group('parseUri — rejects', () {
    test('other sites', () {
      expect(_uri('https://example.com/s/abc123'), isNull);
      expect(_uri('https://recipespellbook.app.evil.com/s/abc123'), isNull);
      expect(_uri('https://notrecipespellbook.app/s/abc123'), isNull);
    });

    test('other schemes (e.g. Google sign-in redirects)', () {
      expect(_uri('com.googleusercontent.apps.123:/oauth2redirect?code=x'), isNull);
      expect(_uri('mailto:someone@example.com'), isNull);
    });

    test('unrelated pages on our site', () {
      expect(_uri('https://recipespellbook.app/'), isNull);
      expect(_uri('https://recipespellbook.app/pricing'), isNull);
    });

    test('codes with invalid characters', () {
      expect(_uri('https://recipespellbook.app/s/ab'), isNull); // too short
      expect(_uri('https://recipespellbook.app/s/abc%20123'), isNull);
    });
  });

  group('parseText', () {
    test('empty / whitespace', () {
      expect(_text(''), isNull);
      expect(_text('   \n'), isNull);
    });

    test('full link', () {
      expect(_text('https://recipespellbook.app/s/abc123'),
          const InviteTarget.shareCode('abc123'));
    });

    test('link inside a message with trailing punctuation', () {
      expect(_text('Join my list! https://recipespellbook.app/s/abc123.'),
          const InviteTarget.shareCode('abc123'));
      expect(_text('(see https://recipespellbook.app/s/abc123)'),
          const InviteTarget.shareCode('abc123'));
    });

    test('share codes ending in - or _ keep them', () {
      expect(_text('https://recipespellbook.app/s/abc12-'),
          const InviteTarget.shareCode('abc12-'));
      expect(_text('https://recipespellbook.app/s/abc12_'),
          const InviteTarget.shareCode('abc12_'));
    });

    test('family share message picks the link over the code', () {
      expect(
        _text('Join my family on Recipe Spellbook! Code: A1B2C3D4 or use this link: '
            'https://recipespellbook.app/family/join/A1B2C3D4'),
        const InviteTarget.familyInviteCode('A1B2C3D4'),
      );
    });

    test('our link is found after a foreign link', () {
      expect(_text('https://example.com/x and https://recipespellbook.app/s/abc123'),
          const InviteTarget.shareCode('abc123'));
    });

    test('only foreign links → null (not a bare code)', () {
      expect(_text('https://example.com/recipes/123'), isNull);
    });

    test('our domain without a scheme', () {
      expect(_text('recipespellbook.app/s/abc123'), const InviteTarget.shareCode('abc123'));
      expect(_text('www.recipespellbook.app/family/join/A1B2C3D4'),
          const InviteTarget.familyInviteCode('A1B2C3D4'));
    });

    test('bare paths', () {
      expect(_text('/s/abc123'), const InviteTarget.shareCode('abc123'));
      expect(_text('s/abc123'), const InviteTarget.shareCode('abc123'));
      expect(_text('family/join/A1B2C3D4'), const InviteTarget.familyInviteCode('A1B2C3D4'));
      expect(_text('foo/bar'), isNull);
    });

    test('custom-scheme links', () {
      expect(_text('recipespellbook://s/abc123'), const InviteTarget.shareCode('abc123'));
      expect(_text('recipespellbook://import?code=abc123'),
          const InviteTarget.shareCode('abc123'));
      expect(_text('recipespellbook://kroger-callback?code=abc123'), isNull);
    });

    test('bare codes are ambiguous', () {
      final t = _text('  A1B2C3D4 ');
      expect(t, const InviteTarget.bareCode('A1B2C3D4'));
      expect(t!.route, isNull);
      expect(_text('aB3_-x'), const InviteTarget.bareCode('aB3_-x'));
    });

    test('labelled code', () {
      expect(_text('Code: A1B2C3D4'), const InviteTarget.bareCode('A1B2C3D4'));
      expect(_text('my invite code: ab12-'), const InviteTarget.bareCode('ab12-'));
    });

    test('prose without a link or code → null', () {
      expect(_text('hello there friend'), isNull);
      expect(_text('ab'), isNull);
    });
  });

  group('helpers', () {
    test('looksLikeFamilyCode', () {
      expect(InviteLinkParser.looksLikeFamilyCode('A1B2C3D4'), isTrue);
      expect(InviteLinkParser.looksLikeFamilyCode('a1b2c3d4'), isTrue);
      expect(InviteLinkParser.looksLikeFamilyCode('abc123'), isFalse);
      expect(InviteLinkParser.looksLikeFamilyCode('G1B2C3D4'), isFalse);
    });

    test('route encodes the value', () {
      expect(const InviteTarget.shareCode('a b').route, '/s/a%20b');
    });
  });
}
