import Decoded

public extension Decoded {
    func validated(by validator: Validator<T>) throws -> Validated<T> {
        try validated(mergingErrors: validator(self))
    }

    func validated(@ValidatorBuilder<T> buildValidator: () -> Validator<T>) throws -> Validated<T> {
        try validated(by: buildValidator())
    }
}

public extension Decoded {
    func map<U>(_ f: (KeyedValue<T>) -> U) -> U? {
        keyedValue.map(f)
    }

    func zip<U1, U2>(_ f1: (KeyedValue<T>) -> U1, _ f2: (KeyedValue<T>) -> U2) -> (U1, U2)? {
        map(f1).flatMap { u1 in
            map(f2).map { u2 in
                (u1, u2)
            }
        }
    }
}

public extension Decoded {
    func flatMap<U>(_ f: (T) -> Decoded<U>) -> KeyedValue<U>? {
        value.map(f).flatMap { decoded in
            decoded.success.map {
                .init(codingPath: decoded.codingPath, success: $0)
            }
        }
    }

    func flatMap<U>(_ keyPath: KeyPath<T, Decoded<U>>) -> KeyedValue<U>? {
        flatMap { $0[keyPath: keyPath] }
    }

    func flatZip<U1, U2>(_ f1: (T) -> Decoded<U1>, _ f2: (T) -> Decoded<U2>) -> (KeyedValue<U1>, KeyedValue<U2>)? {
        flatMap(f1).flatMap { u1 in
            flatMap(f2).map { u2 in
                (u1, u2)
            }
        }
    }

    func flatZip<U1, U2>(_ keyPath1: KeyPath<T, Decoded<U1>>, _ keyPath2: KeyPath<T, Decoded<U2>>) -> (KeyedValue<U1>, KeyedValue<U2>)? {
        flatMap(keyPath1).flatMap { u1 in
            flatMap(keyPath2).map { u2 in
                (u1, u2)
            }
        }
    }
}
