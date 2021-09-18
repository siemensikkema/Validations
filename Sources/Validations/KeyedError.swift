import Decoded

public struct KeyedError {
    public init(codingPath: CodingPath, error: Error) {
        self.codingPath = codingPath
        self.error = error
    }

    let codingPath: CodingPath
    let error: Error
}

extension KeyedError: KeyedErrorsRepresentable {
    var keyedErrors: KeyedErrors? {
        .init(self)
    }
}
