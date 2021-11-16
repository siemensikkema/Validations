import Decoded

/// Enables conforming types to represent a single validation failure. 
public protocol ValidationFailure {}

extension DecodingFailure: ValidationFailure {}
