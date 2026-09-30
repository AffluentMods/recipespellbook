/// Resolve a user's `avatarUrl` to something loadable: absolute URLs pass
/// through; bare storage keys (what the API returns for uploaded avatars) are
/// served from the web avatar endpoint.
String resolveAvatarUrl(String avatarUrl) {
  if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
    return avatarUrl;
  }
  const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.recipespellbook.app',
  );
  return '$apiUrl/v1/web/avatar/$avatarUrl';
}
