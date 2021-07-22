public struct AnyCodingKey: CodingKey, Hashable {
    public let stringValue: String
    public let intValue: Int?

    public var description: String { stringValue }

    init(codingKey: CodingKey) {
        self.stringValue = codingKey.stringValue
        self.intValue = codingKey.intValue
    }

    public init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

extension AnyCodingKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(stringValue: value)
    }
}

extension AnyCodingKey: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(intValue: value)
    }
}
