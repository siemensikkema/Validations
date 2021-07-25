import Checked
import Decoded
import XCTest

final class CheckedTests: XCTestCase {
    func test_directPropertyAccess() throws {
        struct Gadget: Decodable {
            @Decoded<String> var name
        }

        let decoded = try decode(#"{"name":"arduino"}"#, as: Gadget.self)
        let checked = try decoded.checked()
        XCTAssertEqual(checked.name, "arduino")
    }

    func test_directPropertyAccess_nested() throws {
        struct CarRequest: Decodable {
            struct Engine: Decodable {
                @Decoded<Double> var cylinderVolume
            }
            @Decoded<Engine> var engine
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
            let mappedErrors = error.mapErrors { $0 is Decoded<String>.State.TypeMismatch }
            XCTAssertEqual(mappedErrors, [[]: [true]])
        }
    }

    func test_nameConflictWithState() throws {
        struct City: Decodable {
            struct State: Decodable {
                @Decoded<String> var name
            }
            @Decoded<State> var state
        }
        let decoded = try decode(#"{"state":{"name":"NY"}}"#, as: City.self)
        let checked = try decoded.checked()
        XCTAssertEqual(checked.state.name, "NY")
        XCTAssertEqual(checked.$state.codingPath, ["state"])
    }
}
