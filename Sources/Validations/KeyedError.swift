import Decoded

public struct KeyedError {
    public init(codingPath: CodingPath, error: ValidationError) {
        self.codingPath = codingPath
        self.error = error
    }

    let codingPath: CodingPath
    let error: ValidationError
}

extension KeyedError: KeyedErrorsRepresentable {
    public var keyedErrors: KeyedErrors? {
        .init(self)
    }
}
