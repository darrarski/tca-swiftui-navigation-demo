import ComposableArchitecture
import SwiftUI

struct ThirdState: Equatable {
  let timerId = UUID()
  var date: Date?
}

enum ThirdAction: Equatable {
  case didAppear
  case didTimerTick
  case dismissToFirst
  case didDisappear
}

let thirdReducer = Reducer<ThirdState, ThirdAction, AppEnvironment> { state, action, environment in
  switch action {
  case .didAppear:
    return Effect.timer(id: state.timerId, every: 1, on: environment.mainScheduler)
      .map { _ in .didTimerTick }
      .prepend(.didTimerTick)
      .eraseToEffect()

  case .didTimerTick:
    state.date = environment.currentDate()
    return .none

  case .dismissToFirst:
    return .none

  case .didDisappear:
    return .cancel(id: state.timerId)
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
      .onAppear { viewStore.send(.didAppear) }
      .onDisappear { viewStore.send(.didDisappear) }
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
