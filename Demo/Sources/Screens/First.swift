import ComposableArchitecture
import SwiftUI

struct FirstState: Equatable {
  var isPresentingSecond = false
  var second: SecondState?
}

enum FirstAction: Equatable {
  case presentSecond(Bool)
  case second(SecondAction)
}

let firstReducer = Reducer<FirstState, FirstAction, DemoAppEnvironment>.combine(
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
      }
      return .none

    case .second(.didDisappear),
         .second(.third(.didDisappear)):
      if state.isPresentingSecond == false, let second = state.second {
        state.second = nil
        return cancelSecondReducerEffects(state: second)
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
      ScrollView {
        VStack {
          Text("The first screen is a root view of the navigation stack. Tap the button below to push the second screen onto the stack.")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

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
        }
        .frame(maxWidth: .infinity)
        .background(Color.primary.colorInvert())
        .padding()
      }
      .background(Color.blue.ignoresSafeArea())
      .navigationTitle("First")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct FirstView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      FirstView(store: Store(
        initialState: FirstState(),
        reducer: .empty,
        environment: ()
      ))
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
