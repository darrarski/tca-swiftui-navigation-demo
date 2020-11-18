import ComposableArchitecture
import SwiftUI

struct ThirdState: Equatable {
  var date: Date?
}

enum ThirdAction: Equatable {
  case startTimer
  case timerTick
  case dismissToFirst
}

struct TimerId: Hashable {}

let thirdReducer = Reducer<ThirdState, ThirdAction, AppEnvironment> { state, action, environment in
  switch action {
  case .startTimer:
    return Effect.timer(id: TimerId(), every: 1, tolerance: 0, on: environment.mainScheduler)
      .map { _ in ThirdAction.timerTick }
      .prepend(.timerTick)
      .eraseToEffect()

  case .timerTick:
    state.date = environment.currentDate()
    return .none

  case .dismissToFirst:
    return .none
  }
}

struct ThirdViewState: Equatable {
  let date: Date?

  init(state: ThirdState) {
    date = state.date
  }
}

struct ThirdView: View {
  let store: Store<ThirdState, ThirdAction>
  @Environment(\.timeFormatter) var timeFormatter

  init(store: Store<ThirdState, ThirdAction>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store.scope(state: ThirdViewState.init(state:))) { viewStore in
      ZStack {
        Color.yellow.ignoresSafeArea()

        VStack {
          if let date = viewStore.date {
            Text(timeFormatter.string(for: date))
              .padding()
          }

          Button(action: { viewStore.send(.dismissToFirst) }) {
            Text("Dismiss to First")
              .padding()
          }
        }
      }
      .navigationTitle("Third")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear {
        viewStore.send(.startTimer)
      }
    }
  }
}
