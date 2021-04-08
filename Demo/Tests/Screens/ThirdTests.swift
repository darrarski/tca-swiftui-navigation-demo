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

    store.send(.didAppear) {
      $0.timerId = idStub
    }

    XCTAssertTrue(didSubscribeToTimer)
    didSubscribeToTimer = false
    timer.send(Date(timeIntervalSince1970: 0))

    store.receive(.didTimerTick(Date(timeIntervalSince1970: 0))) {
      $0.date = Date(timeIntervalSince1970: 0)
    }

    timer.send(Date(timeIntervalSince1970: 1))

    store.receive(.didTimerTick(Date(timeIntervalSince1970: 1))) {
      $0.date = Date(timeIntervalSince1970: 1)
    }

    store.send(.didDisappear) {
      $0.timerId = nil
    }

    XCTAssertTrue(didCancelTimer)
    didCancelTimer = false

    store.send(.didAppear) {
      $0.timerId = idStub
    }

    XCTAssertTrue(didSubscribeToTimer)
    didSubscribeToTimer = false

    store.send(.didAppear)

    store.send(.didDisappear) {
      $0.timerId = nil
    }

    XCTAssertTrue(didCancelTimer)
    didCancelTimer = false
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
