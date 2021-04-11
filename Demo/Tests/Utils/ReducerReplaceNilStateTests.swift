import ComposableArchitecture
import XCTest
@testable import Demo

final class ReducerReplaceNilStateTests: XCTestCase {
  var reducer: Reducer<String?, Void, Void>!
  var didReduceState: String?

  override func setUp() {
    reducer = Reducer<String?, Void, Void> { state, _, _ in
      self.didReduceState = state
      return .none
    }
    .replaceNilState(with: "REPLACEMENT")
  }

  override func tearDown() {
    reducer = nil
    didReduceState = nil
  }

  func testReducingNonNilState() {
    var state: String? = "TEST"
    _ = reducer.run(&state, (), ())

    XCTAssertEqual(didReduceState, "TEST")
  }

  func testReducingNilState() {
    var state: String? = nil
    _ = reducer.run(&state, (), ())

    XCTAssertEqual(didReduceState, "REPLACEMENT")
    XCTAssertNil(state)
  }
}
