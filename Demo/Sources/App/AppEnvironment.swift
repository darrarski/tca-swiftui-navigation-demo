import Combine
import ComposableArchitecture

struct AppEnvironment {
  var randomId: () -> UUID = UUID.init
  var fetcher: () -> AnyPublisher<Date, Never> = {
    Just(())
      .delay(for: .seconds(3), scheduler: DispatchQueue.main)
      .map(Date.init)
      .eraseToAnyPublisher()
  }
  var timer: () -> AnyPublisher<Date, Never> = {
    Publishers.Timer(every: 1, scheduler: DispatchQueue.main)
      .autoconnect()
      .map { _ in Date() }
      .prepend(Date())
      .eraseToAnyPublisher()
  }
}
