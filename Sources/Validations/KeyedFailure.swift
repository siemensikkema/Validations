import Decoded

struct KeyedFailure {
    let codingPath: CodingPath
    let failure: ValidationFailure
}

extension KeyedFailure: KeyedFailuresRepresentable {
    var keyedFailures: KeyedFailures? {
        .init(self)
    }
}
