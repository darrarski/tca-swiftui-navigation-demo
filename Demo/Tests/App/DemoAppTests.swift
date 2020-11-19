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

    store.assert(
      .send(.first(.presentSecond(true))) {
        $0.first.isPresentingSecond = true
        $0.first.second = SecondState()
      },
      .send(.first(.second(.didAppear))) {
        $0.first.second!.fetchId = latestId
      },
      .receive(.first(.second(.fetchDate))),
      .send(.first(.second(.presentThird(true)))) {
        $0.first.second!.isPresentingThird = true
        $0.first.second!.third = ThirdState()
      },
      .send(.first(.second(.third(.didAppear)))) {
        $0.first.second!.third!.timerId = latestId
      },
      .send(.first(.second(.presentThird(false)))) {
        $0.first.second!.isPresentingThird = false
      },
      .send(.first(.second(.third(.didDisappear)))) {
        $0.first.second!.third = nil
      },
      .send(.first(.presentSecond(false))) {
        $0.first.isPresentingSecond = false
      },
      .send(.first(.second(.didDisappear))) {
        $0.first.second = nil
      }
    )
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

    store.assert(
      .send(.first(.presentSecond(true))) {
        $0.first.isPresentingSecond = true
        $0.first.second = SecondState()
      },
      .send(.first(.second(.didAppear))) {
        $0.first.second!.fetchId = latestId
      },
      .receive(.first(.second(.fetchDate))),
      .send(.first(.second(.presentThird(true)))) {
        $0.first.second!.isPresentingThird = true
        $0.first.second!.third = ThirdState()
      },
      .send(.first(.second(.third(.didAppear)))) {
        $0.first.second!.third!.timerId = latestId
      },
      .send(.first(.second(.third(.dismissToFirst)))),
      .receive(.first(.presentSecond(false))) {
        $0.first.isPresentingSecond = false
      },
      .send(.first(.second(.third(.didDisappear)))) {
        $0.first.second = nil
      }
    )
  }
}
