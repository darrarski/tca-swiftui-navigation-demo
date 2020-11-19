import XCTest
@testable import Demo
import Combine
import ComposableArchitecture

final class ThirdTests: XCTestCase {
  func testTimer() {
    let timerId = UUID()
    let timer = PassthroughSubject<Date, Never>()
    var didCancelTimer = false
    let store = TestStore(
      initialState: ThirdState(
        timerId: timerId,
        date: nil
      ),
      reducer: thirdReducer,
      environment: AppEnvironment(
        randomId: { fatalError() },
        fetcher: { fatalError() },
        timer: {
          timer.handleEvents(receiveCancel: { didCancelTimer = true })
            .eraseToAnyPublisher()
        }
      )
    )

    store.assert(
      .send(.didAppear),
      .do {
        timer.send(Date(timeIntervalSince1970: 0))
      },
      .receive(.didTimerTick(Date(timeIntervalSince1970: 0))) {
        $0.date = Date(timeIntervalSince1970: 0)
      },
      .do {
        timer.send(Date(timeIntervalSince1970: 1))
      },
      .receive(.didTimerTick(Date(timeIntervalSince1970: 1))) {
        $0.date = Date(timeIntervalSince1970: 1)
      },
      .send(.didDisappear),
      .do {
        XCTAssertTrue(didCancelTimer)
      }
    )
  }
}
