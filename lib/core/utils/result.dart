/// Minimal Result type for operations that can fail (e.g. the simulated
/// partial-update call). Avoids pulling in a full fpdart/dartz dependency
/// for something this small.
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}
