import XCTest
@testable import Demo
import ComposableArchitecture

final class FirstTests: XCTestCase {
  func testPresentSecond() {
    let store = TestStore(
      initialState: FirstState(
        isPresentingSecond: false,
        second: nil
      ),
      reducer: firstReducer,
      environment: DemoAppEnvironment(
        randomId: { fatalError() },
        fetcher: { fatalError() },
        timer: { fatalError() }
      )
    )

    store.assert(
      .send(.presentSecond(true)) {
        $0.isPresentingSecond = true
        $0.second = SecondState()
      }
    )
  }

  func testDismissSecond() {
    let store = TestStore(
      initialState: FirstState(
        isPresentingSecond: true,
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

    store.assert(
      .send(.presentSecond(false)) {
        $0.isPresentingSecond = false
      },
      .send(.second(.didDisappear)) {
        $0.second = nil
      }
    )
  }

  func testDismissFromThirdToFirst() {
    let store = TestStore(
      initialState: FirstState(
        isPresentingSecond: true,
        second: SecondState(
          fetchId: UUID(),
          isPresentingThird: true,
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

    store.assert(
      .send(.second(.third(.dismissToFirst))),
      .receive(.presentSecond(false)) {
        $0.isPresentingSecond = false
      },
      .send(.second(.third(.didDisappear))) {
        $0.second = nil
      }
    )
  }
}
