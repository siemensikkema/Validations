import Decoded

public protocol ValidationFailure {}

extension DecodingFailure: ValidationFailure {}
