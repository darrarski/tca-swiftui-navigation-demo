import ComposableArchitecture

extension Reducer {
  /// Captures reduced state.
  ///
  /// - Parameter capture: A closure called when a state is reduced.
  /// - Parameter state: The reduced state value.
  /// - Returns: A reducer that works on `State`, `Action`, `Environment`.
  func captureState(_ capture: @escaping (_ state: State) -> Void) -> Self {
    .init { state, action, environment in
      capture(state)
      return run(&state, action, environment)
    }
  }
}
