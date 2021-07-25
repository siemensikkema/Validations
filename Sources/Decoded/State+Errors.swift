public extension Decoded.State {
    struct Nil: Error {}
    struct Absent: Error {}
    struct TypeMismatch: Error, CustomStringConvertible {
        public let description: String
    }
}
