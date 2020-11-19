import XCTest
@testable import Demo
import Combine
import ComposableArchitecture

final class ThirdTests: XCTestCase {
  func testTimer() {
    let mainScheduler = DispatchQueue.testScheduler
    let timerId = UUID()
    var dateStub: Date!
    let timer = PassthroughSubject<Void, Never>()
    var didCancelTimer = false
    let store = TestStore(
      initialState: ThirdState(
        timerId: timerId,
        date: nil
      ),
      reducer: thirdReducer,
      environment: AppEnvironment(
        mainScheduler: mainScheduler.eraseToAnyScheduler(),
        currentDate: { dateStub },
        randomId: { fatalError() },
        timer: {
          timer.handleEvents(receiveCancel: { didCancelTimer = true })
            .eraseToAnyPublisher()
        }
      )
    )

    store.assert(
      .do { dateStub = Date(timeIntervalSince1970: 0) },
      .send(.didAppear),
      .receive(.didTimerTick) {
        $0.date = dateStub
      },
      .do {
        dateStub = Date(timeIntervalSinceNow: 1)
        timer.send(())
      },
      .receive(.didTimerTick) {
        $0.date = dateStub
      },
      .send(.didDisappear),
      .do { XCTAssertTrue(didCancelTimer) }
    )
  }
}
