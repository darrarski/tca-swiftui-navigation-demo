/// Converts a closure (A) -> B? to a closure that returns last non-`nil` B returned by the input closure
///
/// Based on a code from [Thomvis/Construct repository](https://github.com/Thomvis/Construct/blob/f165fd005cd939560c1a4eb8d6ee55075a52685d/Construct/Foundation/Memoize.swift)
///
/// - Parameter inputClosure: input closure
/// - Returns: output closure
func replayNonNil<A, B>(_ inputClosure: @escaping (A) -> B?) -> (A) -> B? {
  var lastNonNilOutput: B? = nil
  return { inputValue in
    guard let outputValue = inputClosure(inputValue) else {
      return lastNonNilOutput
    }
    lastNonNilOutput = outputValue
    return outputValue
  }
}

/// Creates a closure (T?) -> T? that returns last non-`nil` T passed to it
/// - Returns: closure
func replayNonNil<T>() -> (T?) -> T? {
  replayNonNil { $0 }
}
