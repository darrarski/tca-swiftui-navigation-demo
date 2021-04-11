import ComposableArchitecture

extension Reducer {
  /// Combines the reducer with a reducer that works on optionally presented `LocalState`.
  ///
  /// - All effects returned by the local reducer are canceled when `LocalState` is `nil`.
  /// - If `LocalAction` is sent when `LocalState` is `nil`:
  ///   - The last non-`nil` state value is passed to the local reducer (if available).
  ///   - The `LocalState` is unchanged (it stays `nil`).
  ///   - All effects returned by the local reducer are immediately canceled.
  ///
  /// Based on [Reducer.presents function](https://github.com/pointfreeco/swift-composable-architecture/blob/9ec4b71e5a84f448dedb063a21673e4696ce135f/Sources/ComposableArchitecture/Reducer.swift#L549-L572) from `iso` branch of `swift-composable-architecture` repository.
  ///
  /// - Parameters:
  ///   - localReducer: A reducer that works on `LocalState`, `LocalAction`, `LocalEnvironment`.
  ///   - toLocalState: A key path that can get/set `LocalState?` inside `State`.
  ///   - toLocalAction: A case path that can extract/embed `LocalAction` from `Action`.
  ///   - toLocalEnvironment: A function that transforms `Environment` into `LocalEnvironment`.
  /// - Returns: A reducer that works on `State`, `Action`, `Environment`.
  func presents<LocalState, LocalAction, LocalEnvironment>(
    _ localReducer: Reducer<LocalState, LocalAction, LocalEnvironment>,
    state toLocalState: WritableKeyPath<State, LocalState?>,
    action toLocalAction: CasePath<Action, LocalAction>,
    environment toLocalEnvironment: @escaping (Environment) -> LocalEnvironment
  ) -> Self {
    let localEffectsId = UUID()
    var lastNonNilLocalState: LocalState?
    return Self { state, action, environment in
      let localEffects = localReducer
        .optional()
        .replaceNilState(with: lastNonNilLocalState)
        .captureState { lastNonNilLocalState = $0 ?? lastNonNilLocalState }
        .pullback(state: toLocalState, action: toLocalAction, environment: toLocalEnvironment)
        .run(&state, action, environment)
        .cancellable(id: localEffectsId)
      let globalEffects = run(&state, action, environment)
      let hasLocalState = state[keyPath: toLocalState] != nil
      return .merge(
        localEffects,
        globalEffects,
        hasLocalState ? .none : .cancel(id: localEffectsId)
      )
    }
  }
}
