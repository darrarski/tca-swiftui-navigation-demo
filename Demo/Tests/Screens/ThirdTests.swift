import XCTest
import SnapshotTesting
@testable import Demo
import Combine
import ComposableArchitecture

final class ThirdTests: XCTestCase {
  func testTimer() {
    let idStub = UUID()
    var timer: PassthroughSubject<Date, Never>!
    var didSubscribeToTimer = false
    var didCancelTimer = false
    let store = TestStore(
      initialState: ThirdState(
        timerId: nil,
        date: nil
      ),
      reducer: thirdReducer,
      environment: DemoAppEnvironment(
        randomId: { idStub },
        fetcher: { fatalError() },
        timer: {
          timer = PassthroughSubject()
          return timer
            .handleEvents(
              receiveSubscription: { _ in didSubscribeToTimer = true },
              receiveCancel: { didCancelTimer = true }
            )
            .eraseToAnyPublisher()
        }
      )
    )

    store.assert(
      .send(.didAppear) {
        $0.timerId = idStub
      },
      .do {
        XCTAssertTrue(didSubscribeToTimer)
        didSubscribeToTimer = false
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
      .send(.didDisappear) {
        $0.timerId = nil
      },
      .do {
        XCTAssertTrue(didCancelTimer)
        didCancelTimer = false
      },
      .send(.didAppear) {
        $0.timerId = idStub
      },
      .do {
        XCTAssertTrue(didSubscribeToTimer)
        didSubscribeToTimer = false
      },
      .send(.didAppear),
      .send(.didDisappear) {
        $0.timerId = nil
      },
      .do {
        XCTAssertTrue(didCancelTimer)
        didCancelTimer = false
      }
    )
  }

  func testPreviewSnapshot() {
    assertSnapshot(
      matching: ThirdView_Previews.previews,
      as: .image(
        drawHierarchyInKeyWindow: true,
        layout: .device(config: .iPhoneXr),
        traits: .init(userInterfaceStyle: .light)
      ),
      named: "light"
    )
    assertSnapshot(
      matching: ThirdView_Previews.previews,
      as: .image(
        drawHierarchyInKeyWindow: true,
        layout: .device(config: .iPhoneXr),
        traits: .init(userInterfaceStyle: .dark)
      ),
      named: "dark"
    )
  }
}
