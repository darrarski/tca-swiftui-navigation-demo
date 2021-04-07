import ComposableArchitecture
import SwiftUI

extension View {
  func navigate<State, Action, Destination: View>(
    using store: Store<State?, Action>,
    onDismiss: @escaping () -> Void,
    destination: @escaping (Store<State, Action>) -> Destination
  ) -> some View {
    background(
      IfLetStore(
        store,
        then: { destinationStore in
          NavigationLink(
            destination: destination(destinationStore),
            isActive: Binding(
              get: { true },
              set: { isActive in
                if !isActive {
                  onDismiss()
                }
              }
            ),
            label: EmptyView.init
          )
        }
      )
    )
  }
}
