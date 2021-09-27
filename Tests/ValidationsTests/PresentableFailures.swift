import Validations

/// A basic example of processing validation failures to make them presentable to an end-user.
///
/// More advanced approaches could involve scanning for failures conforming to some protocol to output:
/// - error codes or translation keys (possibly including dynamic data) for client side translation
/// - server-side translated errors based on a language code in the request's `Accept` header.
typealias PresentableFailures = KeyedValues<String>

extension PresentableFailures {
    init(_ keyedFailures: KeyedFailures) {
        self = keyedFailures.mapFailures(\.presentableDescription)
    }
}

extension ValidationFailure {
    var presentableDescription: String {
        guard let presentableFailure = self as? PresentableFailure else {
            return "\(self)"
        }
        return presentableFailure.presentableDescription
    }
}

extension PresentableFailures: CustomStringConvertible {
    public var description: String {
        value.flatMap { codingPath, strings in
            ["\(codingPath.dotPath):"] + strings.map { " - \($0)" }
        }.joined(separator: "\n")
    }
}

protocol PresentableFailure {
    var presentableDescription: String { get }
}