// source: https://github.com/pointfreeco/swift-composable-architecture/blob/8ad45dfd03b2998254a4b5f3e8130ede41be9552/Examples/CaseStudies/SwiftUICaseStudies/04-HigherOrderReducers-Lifecycle.swift

import ComposableArchitecture
import SwiftUI

extension Reducer {
  func lifecycle(
    onAppear: @escaping (Environment) -> Effect<Action, Never> = { _ in .none },
    onDisappear: @escaping (Environment) -> Effect<Never, Never> = { _ in .none }
  ) -> Reducer<State?, LifecycleAction<Action>, Environment> {

    return .init { state, lifecycleAction, environment in
      switch lifecycleAction {
      case .onAppear:
        return onAppear(environment).map(LifecycleAction.action)

      case .onDisappear:
        return onDisappear(environment).fireAndForget()

      case let .action(action):
        guard state != nil else {
          return .none
        }
        return run(&state!, action, environment)
          .map(LifecycleAction.action)
      }
    }
  }
}

enum LifecycleAction<Action> {
  case onAppear
  case onDisappear
  case action(Action)
}

extension LifecycleAction: Equatable where Action: Equatable {}

struct LifecycleView<State, Action, Content>: View where Content: View {
  let store: Store<State?, LifecycleAction<Action>>
  let content: (Store<State, Action>) -> Content

  var body: some View {
    WithViewStore(
      store,
      removeDuplicates: { _, _ in false },
      content: { viewStore in
        IfLetStore(
          store.scope(state: { $0 }, action: LifecycleAction.action),
          then: { store in
            content(store)
              .onAppear { viewStore.send(.onAppear) }
              .onDisappear { viewStore.send(.onDisappear) }
          }
        )
      }
    )
  }
}
