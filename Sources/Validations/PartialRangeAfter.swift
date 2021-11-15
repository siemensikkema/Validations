struct PartialRangeAfter<Bound> where Bound: Comparable {
    let lowerBound: Bound

    init(_ lowerBound: Bound) {
        self.lowerBound = lowerBound
    }
}

extension PartialRangeAfter: RangeExpression {
    func relative<C>(to collection: C) -> Range<Bound> where C : Collection, Bound == C.Index {
        collection.index(after: lowerBound)..<collection.endIndex
    }

    func contains(_ element: Bound) -> Bool {
        lowerBound < element
    }
}
