import ComposableArchitecture
import SwiftUI

struct ThirdState: Equatable {}

enum ThirdAction: Equatable {
  case dismissToFirst
}

let thirdReducer = Reducer<ThirdState, ThirdAction, AppEnvironment>.empty

struct ThirdViewState: Equatable {
  init(state: ThirdState) {}
}

struct ThirdView: View {
  let store: Store<ThirdState, ThirdAction>

  var body: some View {
    WithViewStore(store.scope(state: ThirdViewState.init(state:))) { viewStore in
      ZStack {
        Color.yellow.ignoresSafeArea()

        Button(action: { viewStore.send(.dismissToFirst) }) {
          Text("Dismiss to First")
            .padding()
        }
      }
      .navigationTitle("Third")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
