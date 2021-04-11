import ComposableArchitecture
import XCTest
@testable import Demo

final class ReducerCaptureStateTests: XCTestCase {
  func testStateCapture() {
    var didCaptureState: String?
    let reducer = Reducer<String, Void, Void>.empty.captureState {
      didCaptureState = $0
    }
    var state = "TEST"
    _ = reducer.run(&state, (), ())

    XCTAssertEqual(didCaptureState, "TEST")
  }
}
