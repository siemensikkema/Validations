import Decoded
import Foundation

let decoder = JSONDecoder()

func decode<T: Decodable>(_ string: String, as _: T.Type = T.self) throws -> Decoded<T> {
    try decoder.decode(Decoded<T>.self, from: string.data(using: .utf8)!)
}
