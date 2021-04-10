import ComposableArchitecture

extension Reducer {
  /// Captures reduced state
  /// - Parameter capture: closure called when a state is reduced
  /// - Parameter state: the reduced state value
  /// - Returns: reducer
  func captureState(_ capture: @escaping (_ state: State) -> Void) -> Self {
    .init { state, action, environment in
      capture(state)
      return run(&state, action, environment)
    }
  }
}
