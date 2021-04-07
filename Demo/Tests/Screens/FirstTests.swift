import XCTest
import SnapshotTesting
@testable import Demo
import ComposableArchitecture

final class FirstTests: XCTestCase {
  func testPresentSecond() {
    let store = TestStore(
      initialState: FirstState(
        second: nil
      ),
      reducer: firstReducer,
      environment: DemoAppEnvironment(
        randomId: { fatalError() },
        fetcher: { fatalError() },
        timer: { fatalError() }
      )
    )

    store.send(.presentSecond(true)) {
      $0.second = SecondState()
    }
  }

  func testDismissSecond() {
    let store = TestStore(
      initialState: FirstState(
        second: SecondState(
          fetchId: UUID()
        )
      ),
      reducer: firstReducer,
      environment: DemoAppEnvironment(
        randomId: { fatalError() },
        fetcher: { fatalError() },
        timer: { fatalError() }
      )
    )

    store.send(.presentSecond(false)) {
      $0.second = nil
    }
  }

  func testDismissFromThirdToFirst() {
    let store = TestStore(
      initialState: FirstState(
        second: SecondState(
          fetchId: UUID(),
          third: ThirdState(
            timerId: UUID()
          )
        )
      ),
      reducer: firstReducer,
      environment: DemoAppEnvironment(
        randomId: { fatalError() },
        fetcher: { fatalError() },
        timer: { fatalError() }
      )
    )

    store.send(.second(.third(.dismissToFirst)))

    store.receive(.presentSecond(false)) {
      $0.second = nil
    }
  }

  func testPreviewSnapshot() {
    assertSnapshot(
      matching: FirstView_Previews.previews,
      as: .image(
        drawHierarchyInKeyWindow: true,
        layout: .device(config: .iPhoneXr),
        traits: .init(userInterfaceStyle: .light)
      ),
      named: "light"
    )
    assertSnapshot(
      matching: FirstView_Previews.previews,
      as: .image(
        drawHierarchyInKeyWindow: true,
        layout: .device(config: .iPhoneXr),
        traits: .init(userInterfaceStyle: .dark)
      ),
      named: "dark"
    )
  }
}
