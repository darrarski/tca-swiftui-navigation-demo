import ComposableArchitecture
import SwiftUI

struct ThirdState: Equatable {
  var date: Date?
}

enum ThirdAction: Equatable {
  case startTimer
  case stopTimer
  case timerTick
  case dismissToFirst
}

let timerId = UUID() // FIXME: timer id should be stored in the state (?)

let thirdReducer = Reducer<ThirdState, ThirdAction, AppEnvironment> { state, action, environment in
  switch action {
  case .startTimer:
    return Effect.timer(id: timerId, every: 1, tolerance: 0, on: environment.mainScheduler)
      .map { _ in ThirdAction.timerTick }
      .prepend(.timerTick)
      .eraseToEffect()

  case .stopTimer:
    state.date = nil
    return .cancel(id: timerId)

  case .timerTick:
    state.date = environment.currentDate()
    return .none

  case .dismissToFirst:
    return .none
  }
}

let thirdLifecycleReducer = thirdReducer.lifecycle(
  onAppear: { _ in .init(value: .startTimer) },
  onDisappear: { _ in .cancel(id: timerId) }
)

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
        Color.orange.ignoresSafeArea()

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
        .padding()
        .background(Color.primary.colorInvert())
      }
      .navigationTitle("Third")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct ThirdView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      NavigationLink(
        destination: ThirdView(store: Store(
          initialState: ThirdState(
            date: Date()
          ),
          reducer: .empty,
          environment: ()
        )),
        isActive: .constant(true),
        label: EmptyView.init
      )
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
