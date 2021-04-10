import ComposableArchitecture
import SwiftUI

extension NavigationLink {
  /// Creates `NavigationLink` using a `Store` with an optional `State`.
  ///
  /// - Link is active if `State` is non-`nil` and inactive when it's `nil`.
  /// - Link's destination is generated using last non-`nil` state value.
  ///
  /// - Parameters:
  ///   - store: store with optional state
  ///   - destination: closure that creates link's destination view
  ///   - destinationStore: store with non-optional state
  ///   - action: closure invoked when link is activated or deactivated
  ///   - isActive: determines if the link is active or inactive
  ///   - label: link's label
  /// - Returns: navigation link wrapped in a `WithViewStore` view
  static func store<State, Action, DestinationContent>(
    _ store: Store<State?, Action>,
    destination: @escaping (_ destinationStore: Store<State, Action>) -> DestinationContent,
    action: @escaping (_ isActive: Bool) -> Void,
    label: @escaping () -> Label
  ) -> some View
  where DestinationContent: View,
        Destination == IfLetStore<State, Action, DestinationContent?>
  {
    WithViewStore(store.scope(state: { $0 != nil })) { viewStore in
      NavigationLink(
        destination: IfLetStore(
          store.scope(state: replayNonNil()),
          then: destination
        ),
        isActive: Binding(
          get: { viewStore.state },
          set: action
        ),
        label: label
      )
    }
  }
}

extension View {
  /// Adds `NavigationLink` without a label, using `Store` with an optional `State`.
  ///
  /// - Link is active if `State` is non-`nil` and inactive when it's `nil`.
  /// - Link's destination is generated using last non-`nil` state value.
  ///
  /// - Parameters:
  ///   - store: store with optional state
  ///   - destination: closure that creates link's destination view
  ///   - destinationStore: store with non-optional state
  ///   - onDismiss: closure invoked when link is deactivated
  /// - Returns: view with label-less `NavigationLink` added as a background view
  func navigate<State, Action, DestinationContent>(
    using store: Store<State?, Action>,
    destination: @escaping (_ destinationStore: Store<State, Action>) -> DestinationContent,
    onDismiss: @escaping () -> Void
  ) -> some View
  where DestinationContent: View
  {
    background(
      NavigationLink.store(
        store,
        destination: destination,
        action: { isActive in
          if isActive == false {
            onDismiss()
          }
        },
        label: EmptyView.init
      )
    )
  }
}
