import Checked
import Decoded
import XCTest

final class CheckedTests: XCTestCase {
    func test_directPropertyAccess() throws {
        struct Gadget: Decodable {
            let name: Decoded<String>
        }

        let decoded = try decode(#"{"name":"arduino"}"#, as: Gadget.self)
        let checked = try decoded.checked()
        XCTAssertEqual(checked.name, "arduino")
    }

    func test_directPropertyAccess_nested() throws {
        struct CarRequest: Decodable {
            struct Engine: Decodable {
                let cylinderVolume: Decoded<Double>
            }
            let engine: Decoded<Engine>
        }

        let decoded = try decode(#"{"engine":{"cylinderVolume": 0.9}}"#, as: CarRequest.self)
        let checked = try decoded.checked()
        XCTAssertEqual(checked.engine.cylinderVolume, 0.9)
    }

    func test_checkingFailedDecodingThrowsError() throws {
        let decoded = try decode("0", as: String.self)

        XCTAssertThrowsError(try decoded.checked()) { error in
            guard let error = error as? KeyedErrors else {
                XCTFail("expected error of type `KeyedErrors`")
                return
            }
            let mappedErrors = error.mapErrors { $0 is State<String>.TypeMismatch }
            XCTAssertEqual(mappedErrors, [[]: [true]])
        }
    }

    func test_nameConflictWithState() throws {
        struct City: Decodable {
            let state: Decoded<String>
        }
        let decoded = try decode(#"{"state":"NY"}"#, as: City.self)
        let checked = try decoded.checked()
        XCTAssertEqual(checked.state, "NY")
        XCTAssertEqual(checked.state.codingPath, ["state"])
    }
}
