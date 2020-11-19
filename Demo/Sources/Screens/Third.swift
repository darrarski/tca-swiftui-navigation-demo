import ComposableArchitecture
import SwiftUI

struct ThirdState: Equatable {
  let timerId: UUID
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
    return environment.timer()
      .map { _ in .didTimerTick }
      .prepend(.didTimerTick)
      .eraseToEffect()
      .cancellable(id: state.timerId)

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
      ScrollView {
        VStack {
          Text("The third screen displays the current time. It uses a timer effect, which is bound to the view lifecycle. The timer only ticks when the view is visible. Tap the button below to pop the navigation stack directly to the first view.")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

          if let date = viewStore.date {
            Text(timeFormatter.string(for: date))
              .padding()
          }

          Button(action: { viewStore.send(.dismissToFirst) }) {
            Text("Dismiss to First")
              .padding()
          }
        }
        .frame(maxWidth: .infinity)
        .background(Color.primary.colorInvert())
        .padding()
      }
      .background(Color.orange.ignoresSafeArea())
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
            timerId: UUID(),
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
