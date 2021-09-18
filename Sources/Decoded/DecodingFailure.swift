public struct DecodingFailure: CustomDebugStringConvertible, Equatable, Error, Hashable {
    public enum DecodingErrorType: Equatable, Hashable {
        case dataCorrupted
        case keyNotFound
        case typeMismatch
        case valueNotFound
    }

    public let debugDescription: String
    public let errorType: DecodingErrorType
}

extension DecodingFailure {
    init(decodingError error: DecodingError) throws {
        switch error {
        case .dataCorrupted(let context):
            self.init(debugDescription: context.debugDescription, errorType: .dataCorrupted)
        case .keyNotFound(_, let context):
            self.init(debugDescription: context.debugDescription, errorType: .keyNotFound)
        case .typeMismatch(_, let context):
            self.init(debugDescription: context.debugDescription, errorType: .typeMismatch)
        case .valueNotFound(_, let context):
            self.init(debugDescription: context.debugDescription, errorType: .valueNotFound)
        @unknown default:
            throw error
        }
    }
}
