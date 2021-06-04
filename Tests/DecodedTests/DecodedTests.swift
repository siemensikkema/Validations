import Decoded
import XCTest

final class DecodedTests: XCTestCase {
    func testA() throws {
        struct User: Decodable {
            let name: Decoded<String>
        }
        let payload = """
        { "name": "a" }
        """
        let decoder = JSONDecoder()
        let user = try decoder.decode(Decoded<User>.self, from: payload.data(using: .utf8)!)


        user.

        let keyedErrors = user.keyedErrors()
        XCTAssertFalse(keyedErrors.isEmpty)
        print(keyedErrors)
    }
}


//import Validations
//import XCTest
//
//struct U: Decodable {
//    let tag: Decoded<String>
//}
//struct T: Decodable {
//    let tag: Decoded<String>
//    let u: Decoded<U>
//}
//struct S: Decodable {
//    let tag: Decoded<String>
//    let t: Decoded<T>
//}
//
//final class ValidationsTests: XCTestCase {
//    let decoder = JSONDecoder()
//
//    func decode<T: Decodable>(_: T.Type = T.self, from string: String) throws -> Validated<Decoded<T>> {
//        try decoder.decode(Decoded<T>.self, from: string.data(using: .utf8)!).validations.validated()
//    }
//
//    func decode<T: Validatable>(_: T.Type = T.self, from string: String) throws -> Validated<T> {
//        try decoder.decode(T.self, from: string.data(using: .utf8)!).validations.validated()
//    }
//
//    func testValidatedMemberAccess() throws {
//        XCTAssertEqual(try decode(Int.self, from: "1").value, 1)
//        XCTAssertEqual(try decode([Decoded<Int>].self, from: "[1]")[0].value, 1)
//
//        let s = try decode(S.self, from: """
//        {
//            "tag": "a",
//            "t": { "tag": "b", "u": { "tag": "c" } }
//        }
//        """)
//
//        XCTAssertEqual(s.tag.value, "a")
//        XCTAssertEqual(s.t.tag.value, "b")
//        XCTAssertEqual(s.t.u.tag.value, "c")
//    }
//
//    func testA() {
//
//    }
//}
