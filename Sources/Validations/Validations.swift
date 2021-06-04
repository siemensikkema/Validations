import Checked
import Decoded

public struct Validations<T> {
    let unchecked: Unchecked<T>
    var validationErrors: KeyedErrors = [:]

    mutating func add<U>(_ error: Error, to keyPath: KeyPath<T, Decoded<U>>) {
        guard let value: Decoded<U> = unchecked[dynamicMember: keyPath] else {
            return
        }
        add(error, to: value.codingPath)
    }

    public mutating func add(_ error: Error) {
        add(error, to: unchecked.codingPath)
    }

    private mutating func add(_ error: Error, to codingPath: [BasicCodingKey]) {
        validationErrors[codingPath, default: []].append(error)
    }

    public func validated() throws -> AnyValidated<T> {
        .init(checked: try unchecked.checked(mergingErrors: validationErrors))
    }

    mutating func nested<U>(at keyPath: KeyPath<T, Decoded<U>>, closure: (inout Validations<U>) -> Void) {
        guard let value: Decoded<U> = unchecked[dynamicMember: keyPath] else {
            return
        }
        var validations = value.validations()
        closure(&validations)
        self.validationErrors.merge(validations.validationErrors, uniquingKeysWith: +)
    }

    mutating func withUncheckedValue(_ closure: (Unchecked<T>) -> KeyedErrors) {
        validationErrors.merge(closure(unchecked), uniquingKeysWith: +)
    }
}

public extension Decoded {
    func validations() -> Validations<T> {
        .init(unchecked: unchecked())
    }
}
