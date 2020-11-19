import Combine
import ComposableArchitecture
import SwiftUI

@main
struct DemoApp: App {
  var body: some Scene {
    WindowGroup {
      if isRunningTests == false {
        NavigationView {
          FirstView(store: Store(
            initialState: FirstState(),
            reducer: firstReducer.debug(),
            environment: AppEnvironment()
          ))
        }
        .navigationViewStyle(StackNavigationViewStyle())
      }
    }
  }

  var isRunningTests: Bool {
    ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
  }
}
