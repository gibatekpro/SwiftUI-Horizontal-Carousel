//

import Foundation

/// Wrapper to `Pager` elements. It allows `Pager` to replicate the input data elements if required by the user.
struct PageWrapper<Element, ID>: Equatable, Identifiable where Element: Equatable, ID: Hashable {
    /// This _id_ indicates batch iteration
    var batchId: UInt

    /// `KeyPath` to use as `Element` _id_
    var keyPath: KeyPath<Element, ID>

    /// Wrappes Value
    var element: Element

    /// `Identifiable` _id_
    var id: String {
        "\(batchId)-\(element[keyPath: keyPath])"
    }
}
