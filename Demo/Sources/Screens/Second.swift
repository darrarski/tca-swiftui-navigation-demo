import ComposableArchitecture
import SwiftUI

struct SecondState: Equatable {
  var isPresentingThird = false
  var third: ThirdState?
}

enum SecondAction: Equatable {
  case presentThird(Bool)
  case didDismissThird
  case third(ThirdAction)
}

let secondReducer = Reducer<SecondState, SecondAction, AppEnvironment>.combine(
  thirdReducer.optional().pullback(
    state: \.third,
    action: /SecondAction.third,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case let .presentThird(present):
      state.isPresentingThird = present
      if present {
        state.third = ThirdState()
        return .none
      } else {
        return Effect(value: .didDismissThird)
          .delay(for: environment.stateRemoveOnDismissDelay, scheduler: environment.mainScheduler)
          .eraseToEffect()
      }

    case .didDismissThird:
      if state.isPresentingThird == false {
        state.third = nil
      }
      return .none

    case .third:
      return .none
    }
  }
)

struct SecondViewState: Equatable {
  let isPresentingThird: Bool

  init(state: SecondState) {
    isPresentingThird = state.isPresentingThird
  }
}

struct SecondView: View {
  let store: Store<SecondState, SecondAction>

  var body: some View {
    WithViewStore(store.scope(state: SecondViewState.init(state:))) { viewStore in
      ZStack {
        Color.green.ignoresSafeArea()

        NavigationLink(
          destination: IfLetStore(
            store.scope(
              state: \.third,
              action: SecondAction.third
            ),
            then: ThirdView.init(store:)
          ),
          isActive: viewStore.binding(get: \.isPresentingThird, send: SecondAction.presentThird),
          label: {
            Text("Present Third")
              .padding()
          }
        )
        .padding()
        .background(Color.primary.colorInvert())
      }
      .navigationTitle("Second")
      .navigationBarTitleDisplayMode(.inline)
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
