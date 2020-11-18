import ComposableArchitecture
import SwiftUI

struct FirstState: Equatable {
  var isPresentingSecond = false
  var second: SecondState?
}

enum FirstAction: Equatable {
  case presentSecond(Bool)
  case didDismissSecond
  case second(SecondAction)
}

let firstReducer = Reducer<FirstState, FirstAction, AppEnvironment>.combine(
  secondReducer.optional().pullback(
    state: \.second,
    action: /FirstAction.second,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case let .presentSecond(present):
      state.isPresentingSecond = present
      if present {
        state.second = SecondState()
        return .none
      } else {
        return Effect(value: .didDismissSecond)
          .delay(for: .seconds(1), scheduler: environment.mainScheduler)
          .eraseToEffect()
      }

    case .didDismissSecond:
      if state.isPresentingSecond == false {
        state.second = nil
      }
      return .none

    case .second(.third(.dismissToFirst)):
      return .init(value: .presentSecond(false))

    case .second:
      return .none
    }
  }
)

struct FirstViewState: Equatable {
  let isPresentingSecond: Bool

  init(state: FirstState) {
    isPresentingSecond = state.isPresentingSecond
  }
}

struct FirstView: View {
  let store: Store<FirstState, FirstAction>

  var body: some View {
    WithViewStore(store.scope(state: FirstViewState.init(state:))) { viewStore in
      NavigationLink(
        destination: IfLetStore(
          store.scope(
            state: \.second,
            action: FirstAction.second
          ),
          then: SecondView.init(store:)
        ),
        isActive: viewStore.binding(get: \.isPresentingSecond, send: FirstAction.presentSecond),
        label: {
          Text("Present Second")
            .padding()
        }
      )
      .navigationTitle("First")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
