import Decoded

/// Multiple values keyed by `CodingPath`.
public struct KeyedValues<T> {
    /// The dictionary underlying the `KeyedValues` instance.
    public let value: [CodingPath: [T]]

    private init(_ value: [CodingPath: [T]]) {
        self.value = value
    }
}

extension KeyedValues: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(
            Dictionary(
                uniqueKeysWithValues: value
                    .map { codingPath, values in
                        (codingPath.dotPath, values)
                    }
            )
        )
    }
}

/// Represents an unsuccessful validation with one or more ``ValidationFailure`` values per `CodingPath`.
///
/// ``KeyedFailures`` provides APIs for making the validation failures presentable (see ``KeyedValues``):
/// - `mapFailures(_:)`
/// - `mapFailuresWithCodingPath(_:)`
///
/// As an example, suppose you want to return an error response with error codes for certain failures. You could then define a protocol and conform any ``ValidationFailure`` you want to be associated with an error code:
///
/// ```swift
/// protocol CodedError {
///     var errorCode: Int { get }
/// }
/// ```
///
/// A response to represent your error:
///
/// ```swift
/// struct ErrorResponse: Encodable {
///     let code: Int?
///     let description
///     init(failure: ValidationFailure) {
///         self.code = (failure as? CodedError)?.errorCode
///         self.description = String(describing: failure)
///     }
/// }
/// ```
///
/// And finally, catch the error and map the failures:
///
/// ```swift
/// do {
///     let validated = try decoded.validated()
/// } catch let failures as KeyedFailures {
///     let keyedErrorResponses = failures.mapFailures(ErrorResponse.init)
///     ...
/// }
/// ```
public typealias KeyedFailures = KeyedValues<ValidationFailure>

extension KeyedFailures: Error {}

extension KeyedFailures {
    init(codingPath: CodingPath, failure: T) {
        self.init([codingPath: [failure]])
    }

    mutating func merge(_ other: KeyedFailuresRepresentable?) {
        guard let other = other?.keyedFailures else { return }
        self = .init(value.merging(other.value, uniquingKeysWith: +))
    }

    /// Transforms the validation failures into new types.
    ///
    /// - Parameter transform: Closure that transforms each `ValidationFailure` into a new type.
    /// - Returns: A `KeyedValues` containing the same keys but with transformed values.
    public func mapFailures<U>(_ transform: (T) -> U) -> KeyedValues<U> {
        .init(value.mapValuesEach(transform))
    }

    /// Transforms the validation failures into new types.
    ///
    /// - Parameter transform: Closure that takes a `CodingPath` and `ValidationFailure` and transforms each failure into a new type.
    /// - Returns: A `KeyedValues` containing the same keys but with transformed values.
    public func mapFailuresWithCodingPath<U>(_ transform: (CodingPath, T) -> U) -> KeyedValues<U> {
        .init(value.mapValuesEachWithKey(transform))
    }
}

extension Dictionary where Value: Sequence {
    func mapValuesEach<T>(_ transform: (Value.Element) -> T) -> [Key: [T]] {
        mapValues { values in
            values.map(transform)
        }
    }

    func mapValuesEachWithKey<T>(_ transform: (Key, Value.Element) -> T) -> [Key: [T]] {
        .init(
            uniqueKeysWithValues: map { key, values in
                (key, values.map { transform(key, $0) })
            }
        )
    }
}

extension Optional where Wrapped == KeyedFailures {
    mutating func merge(_ other: KeyedFailuresRepresentable?) {
        self = self.merging(other)
    }
}

extension KeyedFailures {
    init(_ keyedFailure: KeyedFailure) {
        self.init(codingPath: keyedFailure.codingPath, failure: keyedFailure.failure)
    }
}

extension KeyedFailures: KeyedFailuresRepresentable {
    var keyedFailures: KeyedFailures? {
        .init(self)
    }
}
