/// Data-layer exceptions thrown by remote or local data sources.
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'An unexpected server error occurred.']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'An unexpected local cache error occurred.']);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection.']);

  @override
  String toString() => 'NetworkException: $message';
}
