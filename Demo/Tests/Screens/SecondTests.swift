import XCTest
@testable import Demo
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
        mainScheduler: DispatchQueue.testScheduler.eraseToAnyScheduler(),
        currentDate: { fatalError() },
        randomId: { idStub }
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
        mainScheduler: DispatchQueue.testScheduler.eraseToAnyScheduler(),
        currentDate: { fatalError() },
        randomId: { fatalError() }
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
}
