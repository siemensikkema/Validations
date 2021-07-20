import Checked
import Decoded

public struct Validations<T> {
    let unchecked: Unchecked<T>
    var validationErrors: KeyedErrors = [:]

    public mutating func add<U>(_ error: Error, to keyPath: KeyPath<T, Decoded<U>>) {
        guard let value: Decoded<U> = unchecked[dynamicMember: keyPath] else {
            return
        }
        add(error, to: value.codingPath)
    }

    public mutating func add(_ error: Error) {
        add(error, to: unchecked.codingPath)
    }

    public func validated() throws -> AnyValidated<T> {
        .init(checked: try unchecked.checked(mergingErrors: validationErrors))
    }

    public mutating func nested<U>(at keyPath: KeyPath<T, Decoded<U>>, closure: (inout Validations<U>) -> Void) {
        guard let value: Decoded<U> = unchecked[dynamicMember: keyPath] else {
            return
        }
        var validations = value.validations()
        closure(&validations)
        self.validationErrors.merge(validations.validationErrors, uniquingKeysWith: +)
    }
}

private extension Validations {
    mutating func add(_ error: Error, to codingPath: [AnyCodingKey]) {
        validationErrors[codingPath, default: []].append(error)
    }
}

public extension Decoded {
    func validations() -> Validations<T> {
        .init(unchecked: unchecked())
    }
}
