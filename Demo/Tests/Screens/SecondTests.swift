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

    store.send(.presentThird(true)) {
      $0.third = ThirdState()
    }
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

    store.send(.presentThird(false)) {
      $0.third = nil
    }
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

    store.send(.didAppear) {
      $0.fetchId = idStub
    }

    store.receive(.fetchDate)

    fetcher.send(Date(timeIntervalSince1970: 0))

    store.receive(.didFetchDate(Date(timeIntervalSince1970: 0))) {
      $0.fetchedDate = Date(timeIntervalSince1970: 0)
    }

    store.receive(.fetchDate)

    fetcher.send(Date(timeIntervalSince1970: 1))

    store.receive(.didFetchDate(Date(timeIntervalSince1970: 1))) {
      $0.fetchedDate = Date(timeIntervalSince1970: 1)
    }

    store.receive(.fetchDate)

    fetcher.send(Date(timeIntervalSince1970: 2))

    store.receive(.didFetchDate(Date(timeIntervalSince1970: 2))) {
      $0.fetchedDate = Date(timeIntervalSince1970: 2)
    }

    store.receive(.fetchDate)

    store.send(.didAppear)

    fetcher.send(Date(timeIntervalSince1970: 3))

    store.receive(.didFetchDate(Date(timeIntervalSince1970: 3))) {
      $0.fetchedDate = Date(timeIntervalSince1970: 3)
    }

    store.receive(.fetchDate)

    fetcher.send(completion: .finished)
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
