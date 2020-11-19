import XCTest
@testable import Demo
import Combine
import ComposableArchitecture

final class SecondTests: XCTestCase {
  func testPresentThird() {
    let idStub = UUID()
    let store = TestStore(
      initialState: SecondState(
        fetchId: UUID(),
        isPresentingThird: false,
        third: nil
      ),
      reducer: secondReducer,
      environment: AppEnvironment(
        randomId: { idStub },
        fetcher: { fatalError() },
        timer: { fatalError() }
      )
    )

    store.assert(
      .send(.presentThird(true)) {
        $0.isPresentingThird = true
        $0.third = ThirdState(
          timerId: idStub
        )
      }
    )
  }

  func testDismissThird() {
    let store = TestStore(
      initialState: SecondState(
        fetchId: UUID(),
        isPresentingThird: true,
        third: ThirdState(
          timerId: UUID()
        )
      ),
      reducer: secondReducer,
      environment: AppEnvironment(
        randomId: { fatalError() },
        fetcher: { fatalError() },
        timer: { fatalError() }
      )
    )

    store.assert(
      .send(.presentThird(false)) {
        $0.isPresentingThird = false
      },
      .send(.third(.didDisappear)) {
        $0.third = nil
      }
    )
  }

  func testFetch() {
    let idStub = UUID()
    let fetcher = PassthroughSubject<Date, Never>()
    let store = TestStore(
      initialState: SecondState(
        fetchId: idStub
      ),
      reducer: secondReducer,
      environment: AppEnvironment(
        randomId: { fatalError() },
        fetcher: { fetcher.first().eraseToAnyPublisher() },
        timer: { fatalError() }
      )
    )

    store.assert(
      .send(.didAppear),
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
        fetcher.send(completion: .finished)
      }
    )
  }
}
