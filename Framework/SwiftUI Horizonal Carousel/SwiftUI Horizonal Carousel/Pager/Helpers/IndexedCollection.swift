//

// https://www.ralfebert.com/swiftui/mutating-foreach/
public struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    public typealias Index = Base.Index
    public typealias Element = (index: Index, element: Base.Element)

    public let base: Base

    public var startIndex: Index {
        base.startIndex
    }

    public var endIndex: Index {
        base.endIndex
    }

    public func index(after i: Index) -> Index {
        base.index(after: i)
    }

    public func index(before i: Index) -> Index {
        base.index(before: i)
    }

    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }

    public subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

public extension RandomAccessCollection {
    /// Replaces ForEach(Array(myArray.enumerated()), id: \.element.id) notation in SwiftUI
    /// New version: ForEach(myArray.indexed(), id: \.element.id)
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}
