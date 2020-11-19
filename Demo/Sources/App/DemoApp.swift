import Combine
import ComposableArchitecture
import SwiftUI

struct DemoAppState: Equatable {
  var first: FirstState
  var isRunningTests: Bool = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}

enum DemoAppAction: Equatable {
  case first(FirstAction)
}

let demoAppReducer = Reducer<DemoAppState, DemoAppAction, AppEnvironment>.combine(
  firstReducer.pullback(
    state: \.first,
    action: /DemoAppAction.first,
    environment: { $0 }
  )
)

struct DemoAppViewState: Equatable {
  let isPresentingUI: Bool

  init(state: DemoAppState) {
    isPresentingUI = state.isRunningTests == false
  }
}

@main
struct DemoApp: App {
  let store: Store<DemoAppState, DemoAppAction> = Store(
    initialState: DemoAppState(
      first: FirstState()
    ),
    reducer: demoAppReducer.debug(),
    environment: AppEnvironment()
  )

  var body: some Scene {
    WindowGroup {
      WithViewStore(store.scope(state: DemoAppViewState.init(state:))) { viewStore in
        if viewStore.isPresentingUI {
          NavigationView {
            FirstView(store: store.scope(
              state: \.first,
              action: DemoAppAction.first
            ))
          }
          .navigationViewStyle(StackNavigationViewStyle())
        }
      }
    }
  }
}
