import 'dart:convert';

import 'package:archive/archive.dart';
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

  group('parseUri: clip links from the browser extension', () {
    const page = 'https://www.budgetbytes.com/one-pot-chili/';
    const recipeJson = '{"@type":"Recipe","name":"One Pot Chili",'
        '"recipeIngredient":["1 lb beef","1 can beans"],"recipeInstructions":["Brown the beef.","Simmer."]}';
    final data = base64Url.encode(utf8.encode(recipeJson)).replaceAll('=', '');
    final packed = base64Url.encode(Deflate(utf8.encode(recipeJson)).getBytes()).replaceAll('=', '');
    String clip(Map<String, String> params) => Uri(scheme: 'recipespellbook', host: 'clip', queryParameters: params).toString();

    test('a page address on its own', () {
      final target = _uri(clip({'url': page}))!;
      expect(target.kind, InviteTargetKind.clip);
      expect(target.value, page);
      expect(target.clip!.url, page);
      expect(target.clip!.title, isNull);
      expect(target.clip!.jsonLd, isNull);
    });

    test('the encoded link the extension builds', () {
      final link = 'recipespellbook://clip?url=${Uri.encodeComponent('$page?utm_source=x&a=1')}'
          '&title=${Uri.encodeComponent('One Pot Chili | Budget Bytes')}&data=$data';
      final target = _uri(link)!;
      expect(target.clip!.url, '$page?utm_source=x&a=1');
      expect(target.clip!.title, 'One Pot Chili | Budget Bytes');
      expect(target.clip!.jsonLd, recipeJson);
      expect(target.clip!.compressed, isFalse);
    });

    test('compressed data (z=1) is unpacked', () {
      final target = _uri(clip({'url': page, 'data': packed, 'z': '1'}))!;
      expect(target.clip!.jsonLd, recipeJson);
      expect(target.clip!.compressed, isTrue);
    });

    test('padded base64url is read too', () {
      final padded = base64Url.encode(utf8.encode(recipeJson));
      expect(_uri(clip({'url': page, 'data': padded}))!.clip!.jsonLd, recipeJson);
    });

    test('a slash after the host and an upper-case host are tolerated', () {
      expect(_uri('recipespellbook://clip/?url=${Uri.encodeComponent(page)}')!.clip!.url, page);
      expect(_uri('recipespellbook://CLIP?url=${Uri.encodeComponent(page)}')!.clip!.url, page);
    });

    test('route is /clip with the same parameters, and reads back the same', () {
      final target = _uri(clip({'url': page, 'title': 'Chili', 'data': packed, 'z': '1'}))!;
      final route = target.route!;
      expect(route, startsWith('/clip?'));
      final back = Uri.parse(route);
      expect(back.path, ClipRequest.path);
      expect(ClipRequest.fromParameters(back.queryParameters), target.clip);
      expect(ClipRequest.fromParameters(back.queryParameters)!.jsonLd, recipeJson);
    });

    test('route leaves out what was not sent or could not be read', () {
      final route = _uri(clip({'url': page, 'data': 'not base64!'}))!.route!;
      expect(Uri.parse(route).queryParameters, {'url': page});
    });

    test('no page address, or not an http(s) one: no clip', () {
      expect(_uri('recipespellbook://clip'), isNull);
      expect(_uri(clip({'title': 'Chili', 'data': data})), isNull);
      expect(_uri(clip({'url': ''})), isNull);
      expect(_uri(clip({'url': 'javascript:alert(1)'})), isNull);
      expect(_uri(clip({'url': 'file:///C:/Windows/win.ini'})), isNull);
      expect(_uri(clip({'url': 'ftp://example.com/recipe'})), isNull);
      expect(_uri(clip({'url': 'data:text/html,hi'})), isNull);
      expect(_uri(clip({'url': '/one-pot-chili'})), isNull);
      expect(_uri(clip({'url': 'example.com/recipe'})), isNull);
    });

    test('addresses on this device or the local network: no clip', () {
      for (final url in [
        'http://localhost:8080/recipe',
        'http://127.0.0.1/recipe',
        'http://10.0.0.5/recipe',
        'http://192.168.1.1/admin',
        'http://172.20.1.1/',
        'http://169.254.169.254/latest/meta-data',
        'http://[::1]/recipe',
        'http://router/recipe',
        'http://nas.local/recipe',
      ]) {
        expect(_uri(clip({'url': url})), isNull, reason: url);
      }
    });

    test('odd or oversized addresses: no clip', () {
      expect(_uri(clip({'url': 'https://example.com/a recipe'})), isNull);
      expect(_uri(clip({'url': 'https://user:secret@example.com/recipe'})), isNull);
      expect(_uri(clip({'url': 'https://example.com/${'a' * ClipRequest.maxUrlLength}'})), isNull);
    });

    test('data that cannot be read is dropped, the page address stays', () {
      for (final bad in {
        'not base64!': '0',
        base64Url.encode(utf8.encode('not json')): '0',
        base64Url.encode(utf8.encode('"just a string"')): '0',
        base64Url.encode([0xff, 0xfe, 0xfd]): '0',
        data: '1', // not compressed, but said to be
        'A' * (ClipRequest.maxDataLength + 4): '0',
      }.entries) {
        final target = _uri(clip({'url': page, 'data': bad.key, 'z': bad.value}));
        expect(target?.clip?.url, page, reason: bad.key);
        expect(target!.clip!.jsonLd, isNull, reason: bad.key);
        expect(target.clip!.data, isNull, reason: bad.key);
      }
    });

    test('the title is tidied and kept short', () {
      expect(_uri(clip({'url': page, 'title': '  One\tPot\n\nChili  '}))!.clip!.title, 'One Pot Chili');
      expect(_uri(clip({'url': page, 'title': '   '}))!.clip!.title, isNull);
      final long = _uri(clip({'url': page, 'title': 'x' * 500}))!.clip!.title!;
      expect(long.length, ClipRequest.maxTitleLength);
    });

    test('pasted or shared, a clip link is no invite', () {
      expect(_text(clip({'url': page})), isNull);
      expect(_text('look: ${clip({'url': page})}'), isNull);
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
