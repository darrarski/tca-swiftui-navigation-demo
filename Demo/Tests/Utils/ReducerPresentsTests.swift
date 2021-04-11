import Combine
import ComposableArchitecture
import XCTest
@testable import Demo

final class ReducerPresentesTests: XCTestCase {
  func testCancelEffectsOnDismiss() {
    var didSubscribeToEffect = false
    var didCancelEffect = false

    let store = TestStore(
      initialState: MasterState(),
      reducer: masterReducer,
      environment: MasterEnvironment(
        detail: DetailEnvironment(effect: {
          Empty(completeImmediately: false)
            .handleEvents(
              receiveSubscription: { _ in didSubscribeToEffect = true },
              receiveCancel: { didCancelEffect = true }
            )
            .eraseToEffect()
        })
      )
    )

    store.send(.presentDetail) {
      $0.detail = DetailState()
    }

    store.send(.detail(.performEffect))

    XCTAssertTrue(didSubscribeToEffect)
    didSubscribeToEffect = false

    store.send(.dismissDetail) {
      $0.detail = nil
    }

    XCTAssertTrue(didCancelEffect)
    didCancelEffect = false

    // All actions sent to the store at this point will be dispatched with a last non-`nil` state.
    // Effects returned by these actions will be canceled immediately.

    store.send(.detail(.performEffect))

    XCTAssertTrue(didSubscribeToEffect)
    XCTAssertTrue(didCancelEffect)
  }
}

// MARK: - Master component

private struct MasterState: Equatable {
  var detail: DetailState?
}

private enum MasterAction: Equatable {
  case presentDetail
  case dismissDetail
  case detail(DetailAction)
}

private struct MasterEnvironment {
  var detail: DetailEnvironment
}

private typealias MasterReducer = Reducer<MasterState, MasterAction, MasterEnvironment>

private let masterReducer = MasterReducer { state, action, env in
  switch action {
  case .presentDetail:
    state.detail = DetailState()
    return .none

  case .dismissDetail:
    state.detail = nil
    return .none

  case .detail:
    return .none
  }
}
.presents(
  detailReducer,
  state: \.detail,
  action: /MasterAction.detail,
  environment: \.detail
)

// MARK: - Detail component

private struct DetailState: Equatable {}

private enum DetailAction: Equatable {
  case performEffect
  case didPerformEffect
}

private struct DetailEnvironment {
  var effect: () -> Effect<Void, Never>
}

private typealias DetailReducer = Reducer<DetailState, DetailAction, DetailEnvironment>

private let detailReducer = DetailReducer { state, action, env in
  switch action {
  case .performEffect:
    return env.effect()
      .map { _ in DetailAction.didPerformEffect }
      .eraseToEffect()

  case .didPerformEffect:
    return .none
  }
}
