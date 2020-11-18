import ComposableArchitecture
import SwiftUI

struct SecondState: Equatable {
  let timerId = UUID()
  var date: Date?
  var isPresentingThird = false
  var third: ThirdState?
}

enum SecondAction: Equatable {
  case didAppear
  case didTimerTick
  case presentThird(Bool)
  case third(ThirdAction)
  case didDisappear
}

let secondReducer = Reducer<SecondState, SecondAction, AppEnvironment>.combine(
  thirdReducer.optional().pullback(
    state: \.third,
    action: /SecondAction.third,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .didAppear:
      return Effect.timer(id: state.timerId, every: .seconds(1), on: environment.mainScheduler)
        .map { _ in .didTimerTick }
        .prepend(.didTimerTick)
        .eraseToEffect()

    case .didTimerTick:
      state.date = environment.currentDate()
      return .none

    case let .presentThird(present):
      state.isPresentingThird = present
      if present {
        state.third = ThirdState()
      }
      return .none

    case .third(.didDisappear):
      if state.isPresentingThird == false {
        state.third = nil
      }
      return .none

    case .third:
      return .none

    case .didDisappear:
      return .cancel(id: state.timerId)
    }
  }
)

struct SecondViewState: Equatable {
  let date: Date?
  let isPresentingThird: Bool

  init(state: SecondState) {
    date = state.date
    isPresentingThird = state.isPresentingThird
  }
}

struct SecondView: View {
  let store: Store<SecondState, SecondAction>
  @Environment(\.timeFormatter) var timeFormatter

  init(store: Store<SecondState, SecondAction>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store.scope(state: SecondViewState.init(state:))) { viewStore in
      ZStack {
        Color.green.ignoresSafeArea()

        VStack {
          if let date = viewStore.date {
            Text(timeFormatter.string(for: date))
              .padding()
          }

          NavigationLink(
            destination: IfLetStore(
              store.scope(
                state: \.third,
                action: SecondAction.third
              ),
              then: ThirdView.init(store:)
            ),
            isActive: viewStore.binding(
              get: \.isPresentingThird,
              send: SecondAction.presentThird
            ),
            label: {
              Text("Present Third")
                .padding()
            }
          )
        }
        .padding()
        .background(Color.primary.colorInvert())
      }
      .navigationTitle("Second")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear { viewStore.send(.didAppear) }
      .onDisappear { viewStore.send(.didDisappear) }
    }
  }
}

struct SecondView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      NavigationLink(
        destination: SecondView(store: Store(
          initialState: SecondState(),
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
