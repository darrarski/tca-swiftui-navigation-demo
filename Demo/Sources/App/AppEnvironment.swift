import ComposableArchitecture

struct AppEnvironment {
  var mainScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
}
