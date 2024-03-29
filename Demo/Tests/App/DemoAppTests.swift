import XCTest
@testable import Demo
import Combine
import ComposableArchitecture

final class DemoAppTests: XCTestCase {
  func testShouldNotPresentUIWhenTesting() {
    let state = DemoAppState(first: FirstState())
    let viewState = DemoAppViewState(state: state)
    XCTAssertFalse(viewState.isPresentingUI)
  }

  func testPushSecondPushThirdPopThirdPopSecond() {
    var latestId: UUID!
    let store = TestStore(
      initialState: DemoAppState(
        first: FirstState(),
        isRunningTests: false
      ),
      reducer: demoAppReducer,
      environment: DemoAppEnvironment(
        randomId: {
          latestId = UUID()
          return latestId
        },
        fetcher: {
          Empty(completeImmediately: false).eraseToAnyPublisher()
        },
        timer: {
          Empty(completeImmediately: false).eraseToAnyPublisher()
        }
      )
    )

    store.send(.first(.presentSecond(true))) {
      $0.first.second = SecondState()
    }

    store.send(.first(.second(.didAppear))) {
      $0.first.second!.fetchId = latestId
    }

    store.receive(.first(.second(.fetchDate)))

    store.send(.first(.second(.presentThird(true)))) {
      $0.first.second!.third = ThirdState()
    }

    store.send(.first(.second(.third(.didAppear)))) {
      $0.first.second!.third!.timerId = latestId
    }

    store.send(.first(.second(.presentThird(false)))) {
      $0.first.second!.third = nil
    }

    store.send(.first(.presentSecond(false))) {
      $0.first.second = nil
    }
  }

  func testPushSecondPushThirdPopToFirst() {
    var latestId: UUID!
    let store = TestStore(
      initialState: DemoAppState(
        first: FirstState(),
        isRunningTests: false
      ),
      reducer: demoAppReducer,
      environment: DemoAppEnvironment(
        randomId: {
          latestId = UUID()
          return latestId
        },
        fetcher: {
          Empty(completeImmediately: false).eraseToAnyPublisher()
        },
        timer: {
          Empty(completeImmediately: false).eraseToAnyPublisher()
        }
      )
    )

    store.send(.first(.presentSecond(true))) {
      $0.first.second = SecondState()
    }

    store.send(.first(.second(.didAppear))) {
      $0.first.second!.fetchId = latestId
    }

    store.receive(.first(.second(.fetchDate)))

    store.send(.first(.second(.presentThird(true)))) {
      $0.first.second!.third = ThirdState()
    }

    store.send(.first(.second(.third(.didAppear)))) {
      $0.first.second!.third!.timerId = latestId
    }

    store.send(.first(.second(.third(.dismissToFirst))))

    store.receive(.first(.presentSecond(false))) {
      $0.first.second = nil
    }
  }
}
