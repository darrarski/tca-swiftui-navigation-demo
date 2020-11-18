import ComposableArchitecture
import SwiftUI

struct ThirdState: Equatable {}

enum ThirdAction: Equatable {
  case dismissToFirst
}

let thirdReducer = Reducer<ThirdState, ThirdAction, AppEnvironment>.empty

struct ThirdView: View {
  let store: Store<ThirdState, ThirdAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        Color.yellow.ignoresSafeArea()

        Button(action: { viewStore.send(.dismissToFirst) }) {
          Text("Dismiss to First")
        }
      }
      .navigationTitle("Third")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
