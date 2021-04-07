import XCTest
import SnapshotTesting
@testable import Demo
import Combine
import ComposableArchitecture

final class SecondTests: XCTestCase {
  func testPresentThird() {
    let store = TestStore(
      initialState: SecondState(
        fetchId: UUID(),
        third: nil
      ),
      reducer: secondReducer,
      environment: DemoAppEnvironment(
        randomId: { fatalError() },
        fetcher: { fatalError() },
        timer: { fatalError() }
      )
    )

    store.assert(
      .send(.presentThird(true)) {
        $0.third = ThirdState()
      }
    )
  }

  func testDismissThird() {
    let store = TestStore(
      initialState: SecondState(
        fetchId: UUID(),
        third: ThirdState(
          timerId: UUID()
        )
      ),
      reducer: secondReducer,
      environment: DemoAppEnvironment(
        randomId: { fatalError() },
        fetcher: { fatalError() },
        timer: { fatalError() }
      )
    )

    store.assert(
      .send(.presentThird(false)) {
        $0.third = nil
      }
    )
  }

  func testFetch() {
    let idStub = UUID()
    let fetcher = PassthroughSubject<Date, Never>()
    let store = TestStore(
      initialState: SecondState(),
      reducer: secondReducer,
      environment: DemoAppEnvironment(
        randomId: { idStub },
        fetcher: { fetcher.first().eraseToAnyPublisher() },
        timer: { fatalError() }
      )
    )

    store.assert(
      .send(.didAppear) {
        $0.fetchId = idStub
      },
      .receive(.fetchDate),
      .do {
        fetcher.send(Date(timeIntervalSince1970: 0))
      },
      .receive(.didFetchDate(Date(timeIntervalSince1970: 0))) {
        $0.fetchedDate = Date(timeIntervalSince1970: 0)
      },
      .receive(.fetchDate),
      .do {
        fetcher.send(Date(timeIntervalSince1970: 1))
      },
      .receive(.didFetchDate(Date(timeIntervalSince1970: 1))) {
        $0.fetchedDate = Date(timeIntervalSince1970: 1)
      },
      .receive(.fetchDate),
      .do {
        fetcher.send(Date(timeIntervalSince1970: 2))
      },
      .receive(.didFetchDate(Date(timeIntervalSince1970: 2))) {
        $0.fetchedDate = Date(timeIntervalSince1970: 2)
      },
      .receive(.fetchDate),
      .send(.didAppear),
      .do {
        fetcher.send(Date(timeIntervalSince1970: 3))
      },
      .receive(.didFetchDate(Date(timeIntervalSince1970: 3))) {
        $0.fetchedDate = Date(timeIntervalSince1970: 3)
      },
      .receive(.fetchDate),
      .do {
        fetcher.send(completion: .finished)
      }
    )
  }

  func testPreviewSnapshot() {
    assertSnapshot(
      matching: SecondView_Previews.previews,
      as: .image(
        drawHierarchyInKeyWindow: true,
        layout: .device(config: .iPhoneXr),
        traits: .init(userInterfaceStyle: .light)
      ),
      named: "light"
    )
    assertSnapshot(
      matching: SecondView_Previews.previews,
      as: .image(
        drawHierarchyInKeyWindow: true,
        layout: .device(config: .iPhoneXr),
        traits: .init(userInterfaceStyle: .dark)
      ),
      named: "dark"
    )
  }
}
