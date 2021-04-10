import ComposableArchitecture

extension Reducer {
  /// Replaces `nil` state with provided value
  ///
  /// - If reducer is run with non-`nil` state its behavior is unchanged
  /// - If reducer is run with a `nil` state, replacement state is used instead
  /// - When replacement state is used, the original state wont be mutated!
  ///
  /// - Parameter replacement: the replacement state value
  /// - Returns: reducer
  func replaceNilState<S>(
    with replacement: @escaping @autoclosure () -> S?
  ) -> Self where State == Optional<S> {
    .init { state, action, environment in
      guard state != nil else {
        var replacedState = replacement()
        return run(&replacedState, action, environment)
      }
      return run(&state, action, environment)
    }
  }
}
