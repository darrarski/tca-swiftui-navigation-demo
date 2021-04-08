import ComposableArchitecture
import SwiftUI

/// NavigationLink wrapper that can be used with ComposableArchitecture's `Store` with optional `State`
/// - Uses `Store` with optional `State`
/// - Link is active if `State` != `nil`
/// - Contains no visual representation of the link button (uses `EmptyView` as a label)
/// - When link is deactivated, `onDismiss` closure is called (call action that updates parent store in it)
/// - When `State` is `nil`, last non-`nil` `State` is used to bake the destination view (so the view does not
///   disappear during pop transition, when dismiss it triggered programmatically)
struct NavigationLinkView<State, Action, Destination: View>: View {
  init(
    store: Store<State?, Action>,
    onDismiss: @escaping () -> Void,
    destination: @escaping (Store<State, Action>) -> Destination
  ) {
    self.store = store
    self.onDismiss = onDismiss
    self.destination = destination
    self.viewStore = ViewStore(
      store,
      removeDuplicates: { ($0 != nil) == ($1 != nil) }
    )
  }

  let store: Store<State?, Action>
  let onDismiss: () -> Void
  let destination: (Store<State, Action>) -> Destination
  @ObservedObject var viewStore: ViewStore<State?, Action>
  @SwiftUI.State var lastState: State?

  var body: some View {
    NavigationLink(
      destination: IfLetStore(
        store.scope(state: { $0 ?? lastState }),
        then: destination
      ),
      isActive: Binding(
        get: { viewStore.state != nil },
        set: { isActive in
          if isActive == false {
            onDismiss()
          }
        }
      ),
      label: EmptyView.init
    )
    .onReceive(viewStore.publisher) { state in
      if let state = state {
        lastState = state
      }
    }
  }
}

extension View {
  func navigate<State, Action, Destination: View>(
    using store: Store<State?, Action>,
    onDismiss: @escaping () -> Void,
    destination: @escaping (Store<State, Action>) -> Destination
  ) -> some View {
    background(
      NavigationLinkView(
        store: store,
        onDismiss: onDismiss,
        destination: destination
      )
    )
  }
}
