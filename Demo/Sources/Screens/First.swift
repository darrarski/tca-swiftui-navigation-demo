import ComposableArchitecture
import SwiftUI

struct FirstState: Equatable {
  var second: SecondState?
}

enum FirstAction: Equatable {
  case presentSecond(Bool)
  case second(SecondAction)
}

let firstReducer = Reducer<FirstState, FirstAction, DemoAppEnvironment> { state, action, environment in
  switch action {
  case let .presentSecond(present):
    state.second = present ? SecondState() : nil
    return .none

  case .second(.third(.dismissToFirst)):
    return .init(value: .presentSecond(false))

  case .second:
    return .none
  }
}
.presents(
  secondReducer,
  state: \.second,
  action: /FirstAction.second,
  environment: { $0 }
)

struct FirstViewState: Equatable {
  init(state: FirstState) {}
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

          Button(action: { viewStore.send(.presentSecond(true)) }) {
            Text("Present Second")
              .padding()
          }
        }
        .frame(maxWidth: .infinity)
        .background(Color.primary.colorInvert())
        .padding()
      }
      .background(Color.blue.ignoresSafeArea())
      .navigationTitle("First")
      .navigationBarTitleDisplayMode(.inline)
    }
    .navigate(
      using: store.scope(
        state: \.second,
        action: FirstAction.second
      ),
      destination: SecondView.init(store:),
      onDismiss: {
        ViewStore(store.stateless).send(.presentSecond(false))
      }
    )
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
