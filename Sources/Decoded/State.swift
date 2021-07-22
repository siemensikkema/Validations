public enum State<T> {
    case absent
    case `nil`
    case value(T)
    case typeMismatch(String)
}

extension State: Equatable where T: Equatable {}

public extension State {
//    func requireValue() throws -> T {
    var value: T {
        get throws {
            func valueAsNil() -> T? {
                (T.self as? ExpressibleByNilLiteral.Type)?.init(nilLiteral: ()) as? T
            }

            switch self {
            case .value(let value):
                return value
            case .absent:
                guard let value = valueAsNil() else {
                    throw Absent()
                }
                return value
            case .nil:
                guard let value = valueAsNil() else {
                    throw Nil()
                }
                return value
            case .typeMismatch(let description):
                throw TypeMismatch(description: description)
            }
        }
    }
}
