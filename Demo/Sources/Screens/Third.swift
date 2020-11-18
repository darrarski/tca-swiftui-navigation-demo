import ComposableArchitecture
import SwiftUI

struct ThirdState: Equatable {
  var date: Date?
}

enum ThirdAction: Equatable {
  case dismissToFirst
}

let thirdReducer = Reducer<ThirdState, ThirdAction, AppEnvironment>.empty

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
    }
  }
}
