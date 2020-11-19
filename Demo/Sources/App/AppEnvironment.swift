import Combine
import ComposableArchitecture

struct AppEnvironment {
  var mainScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
  var currentDate: () -> Date = Date.init
  var randomId: () -> UUID = UUID.init
  var fetcher: () -> AnyPublisher<Void, Never> = {
    Just(())
      .delay(for: .seconds(3), scheduler: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  var timer: () -> AnyPublisher<Void, Never> = {
    Publishers.Timer(every: 1, scheduler: DispatchQueue.main)
      .autoconnect()
      .map { _ in () }
      .eraseToAnyPublisher()
  }
}
