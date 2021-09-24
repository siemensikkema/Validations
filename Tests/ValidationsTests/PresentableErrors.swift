import Validations

/// A basic example of processing validation errors to make them presentable to an end-user.
///
/// More advanced approaches could involve scanning for errors conforming to some protocol to output:
/// - error codes or translation keys (possibly including dynamic data) for client side translation
/// - server-side translated errors based on a language code in the request's `Accept` header.
typealias PresentableErrors = KeyedValues<String>

extension PresentableErrors {
    init(_ keyedErrors: KeyedErrors) {
        self = keyedErrors.mapErrors(\.presentableDescription)
    }
}

extension Error {
    var presentableDescription: String {
        guard let presentableError = self as? PresentableError else {
            return "\(self)"
        }
        return presentableError.presentableDescription
    }
}

extension PresentableErrors: CustomStringConvertible {
    public var description: String {
        value.flatMap { codingPath, strings in
            ["\(codingPath.dotPath):"] + strings.map { " - \($0)" }
        }.joined(separator: "\n")
    }
}

protocol PresentableError {
    var presentableDescription: String { get }
}
