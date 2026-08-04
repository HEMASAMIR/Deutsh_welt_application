abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

/// HTTP 429 — Too Many Requests (rate limiting)
class RateLimitFailure extends Failure {
  const RateLimitFailure(super.message);
}

/// HTTP 502 — Bad Gateway (usually Bunny Stream CDN unreachable)
class BunnyStreamFailure extends Failure {
  const BunnyStreamFailure(super.message);
}

