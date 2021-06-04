public struct DecodingErrors: Error {
    public let keyedErrors: KeyedErrors

    init?(keyedErrors: KeyedErrors) {
        guard !keyedErrors.isEmpty else {
            return nil
        }
        self.keyedErrors = keyedErrors
    }
}

