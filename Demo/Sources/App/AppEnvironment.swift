import ComposableArchitecture

struct AppEnvironment {
  var mainScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
  var currentDate: () -> Date = Date.init
}
