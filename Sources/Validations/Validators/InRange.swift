import Decoded

public struct InRange<T>: ValidatorExpressible {
    public struct Failure<R: RangeExpression>: ValidationFailure {
        public let value: R.Bound
        public let range: R

        init?(_ value: R.Bound, _ range: R) {
            guard !range.contains(value) else {
                return nil
            }
            self.value = value
            self.range = range
        }
    }

    public let validator: Validator<T>

    public init<R: RangeExpression>(_ keyPath: KeyPath<T, Decoded<R.Bound>>, _ range: R) {
        self.validator = .init(keyPath) { Failure($0.value, range) }
    }
}
