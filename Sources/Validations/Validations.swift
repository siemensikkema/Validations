import Checked
import Decoded

public struct Validations<T> {
    let decoded: Decoded<T>
    var keyedErrors: KeyedErrors? = nil

    public mutating func add<U>(_ error: Error, to keyPath: KeyPath<T, Decoded<U>>) {
        do {
            add(error, to: try decoded.result.value[keyPath: keyPath].codingPath)
        } catch {
            // ignore
        }
    }

    public mutating func add(_ error: Error) {
        add(error, to: decoded.codingPath)
    }

    public func validated() throws -> AnyValidated<T> {
        .init(checked: try decoded.checked(mergingErrors: keyedErrors))
    }

    public mutating func nested<U>(at keyPath: KeyPath<T, Decoded<U>>, closure: (inout Validations<U>) -> Void) {
        do {
            var validations = Validations<U>(decoded: try decoded.result.value[keyPath: keyPath])
            closure(&validations)
            keyedErrors.merge(validations.keyedErrors)
        } catch {
            // ignore
        }
    }
}

private extension Validations {
    mutating func add(_ error: Error, to codingPath: CodingPath) {
        keyedErrors?.merge(.init(codingPath: codingPath, error: error))
    }
}
