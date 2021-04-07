import Combine
import ComposableArchitecture
import SwiftUI

struct SecondState: Equatable {
  var fetchId: UUID?
  var fetchedDate: Date?
  var third: ThirdState?
}

enum SecondAction: Equatable {
  case didAppear
  case fetchDate
  case didFetchDate(Date)
  case presentThird(Bool)
  case third(ThirdAction)
}

let secondReducer = Reducer<SecondState, SecondAction, DemoAppEnvironment> { state, action, environment in
  switch action {
  case .didAppear:
    if state.fetchId == nil {
      state.fetchId = environment.randomId()
      return .init(value: .fetchDate)
    }
    return .none

  case .fetchDate:
    return environment.fetcher()
      .map(SecondAction.didFetchDate)
      .eraseToEffect()
      .cancellable(id: state.fetchId, cancelInFlight: true)

  case let .didFetchDate(date):
    state.fetchedDate = date
    return Effect(value: .fetchDate)

  case let .presentThird(present):
    state.third = present ? ThirdState() : nil
    return .none

  case .third:
    return .none
  }
}
.presents(
  thirdReducer,
  cancelEffectsOnDismiss: true,
  state: \.third,
  action: /SecondAction.third,
  environment: { $0 }
)

struct SecondViewState: Equatable {
  let fetchedDate: Date?

  init(state: SecondState) {
    fetchedDate = state.fetchedDate
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
      ScrollView {
        VStack {
          Text("The second screen fetches the current date every three seconds. This is a use case of subscribing to a long-running effect. Tap the button below to push the third screen onto the navigation stack.")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

          if let date = viewStore.fetchedDate {
            Text(timeFormatter.string(for: date))
              .padding()
          }

          Button(action: { viewStore.send(.presentThird(true)) }) {
            Text("Present Third")
              .padding()
          }
        }
        .frame(maxWidth: .infinity)
        .background(Color.primary.colorInvert())
        .padding()
      }
      .background(Color.green.ignoresSafeArea())
      .navigationTitle("Second")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear { viewStore.send(.didAppear) }
    }
    .navigate(
      using: store.scope(
        state: \.third,
        action: SecondAction.third
      ),
      onDismiss: {
        ViewStore(store.stateless).send(.presentThird(false))
      },
      destination: ThirdView.init(store:)
    )
  }
}

struct SecondView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      NavigationLink(
        destination: SecondView(store: Store(
          initialState: SecondState(
            fetchId: UUID(),
            fetchedDate: Date(timeIntervalSince1970: 0)
          ),
          reducer: .empty,
          environment: ()
        )),
        isActive: .constant(true),
        label: EmptyView.init
      )
    }
    .navigationViewStyle(StackNavigationViewStyle())
    .environment(\.timeFormatter, .preview)
  }
}
