import Decoded

public struct IsEqual<T>: ValidatorExpressible {
    public struct Failure<U: Equatable>: ValidationFailure {
        public let lhs, rhs: U
        public let codingPath: CodingPath?

        init?(_ lhs: U, _ rhs: U, codingPath: CodingPath? = nil) {
            guard lhs != rhs else {
                return nil
            }
            self.codingPath = codingPath
            self.lhs = lhs
            self.rhs = rhs
        }
    }

    public let validator: Validator<T>

    public init<U: Equatable>(_ keyPath: KeyPath<T, Decoded<U>>, _ rhs: U) {
        self.validator = .init(keyPath) { Failure($0.value, rhs) }
    }

    public init<U: Equatable>(_ keyPath1: KeyPath<T, Decoded<U>>, _ keyPath2: KeyPath<T, Decoded<U>>) {
        self.validator = .init(keyPath1, keyPath2) { Failure($0.value, $1.value, codingPath: $1.codingPath) }
    }
}
