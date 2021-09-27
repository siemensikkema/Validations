import Decoded

public struct KeyedError {
    let codingPath: CodingPath
    let error: Error
}

extension KeyedError: KeyedErrorsRepresentable {
    var keyedErrors: KeyedErrors? {
        .init(self)
    }
}
