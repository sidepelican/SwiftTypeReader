import XCTest
@testable import SwiftTypeReader

func XCTReadTypes(_ source: String, file: StaticString = #file, line: UInt = #line) throws -> Module {
    return try Reader().read(source: source)
}

final class SwiftTypeReaderTests: XCTestCase {
    func testSimple() throws {
        let result = try XCTReadTypes("""
struct S {
    var a: Int?
}
"""
        )

        let s = try XCTUnwrap(result.types[safe: 0]?.struct)
        XCTAssertEqual(s.name, "S")

        XCTAssertEqual(s.storedProperties.count, 1)
        let a = try XCTUnwrap(s.storedProperties[safe: 0])
        XCTAssertEqual(a.name, "a")

        let aType = try XCTUnwrap(a.type.struct)
        XCTAssertEqual(aType.name, "Optional")
        XCTAssertEqual(aType.genericsArguments.count, 1)

        let aWrappedType = try XCTUnwrap(aType.genericsArguments[safe: 0]?.struct)
        XCTAssertEqual(aWrappedType.name, "Int")
    }

    func testReader() throws {
        let result = try XCTReadTypes("""
struct S1 {
    var a: Int
    var b: S2
}

struct S2 {
    var a: Int
}
"""
        )

        do {
            let s1 = try XCTUnwrap(result.types[safe: 0]?.struct)
            XCTAssertEqual(s1.name, "S1")

            let a = try XCTUnwrap(s1.storedProperties[safe: 0])
            XCTAssertEqual(a.name, "a")
            XCTAssertEqual(a.type.name, "Int")

            let b = try XCTUnwrap(s1.storedProperties[safe: 1])
            XCTAssertEqual(b.name, "b")

            let s2 = try XCTUnwrap(b.type.struct)
            XCTAssertEqual(s2.name, "S2")
            XCTAssertEqual(s2.storedProperties.count, 1)
        }

        do {
            let s2 = try XCTUnwrap(result.types[safe: 1]?.struct)
            XCTAssertEqual(s2.name, "S2")

            let a = try XCTUnwrap(s2.storedProperties[safe: 0])
            XCTAssertEqual(a.name, "a")
            XCTAssertEqual(a.type.name, "Int")
        }

    }

    func testUnresolved() throws {
        let result = try XCTReadTypes("""
struct S {
    var a: URL
}
"""
        )

        let s = try XCTUnwrap(result.types[safe: 0]?.struct)

        let a = try XCTUnwrap(s.storedProperties[safe: 0]?.type.unresolved)
        XCTAssertEqual(a.name, "URL")
    }

    func testEnum() throws {
        let result = try XCTReadTypes("""
enum E {
    case a
    case b(Int)
    case c(x: Int, y: Int)
}
"""
        )

        let e = try XCTUnwrap(result.types[safe: 0]?.enum)

        do {
            let c = try XCTUnwrap(e.caseElements[safe: 0])
            XCTAssertEqual(c.name, "a")
        }

        do {
            let c = try XCTUnwrap(e.caseElements[safe: 1])
            XCTAssertEqual(c.name, "b")

            let x = try XCTUnwrap(c.associatedValues[safe: 0])
            XCTAssertNil(x.name)
            XCTAssertEqual(x.type.name, "Int")
        }

        do {
            let c = try XCTUnwrap(e.caseElements[safe: 2])
            XCTAssertEqual(c.name, "c")

            let x = try XCTUnwrap(c.associatedValues[safe: 0])
            XCTAssertEqual(x.name, "x")
            XCTAssertEqual(x.type.name, "Int")

            let y = try XCTUnwrap(c.associatedValues[safe: 1])
            XCTAssertEqual(y.name, "y")
            XCTAssertEqual(y.type.name, "Int")
        }
    }

    func testObservedStoredProperty() throws {
        let result = try XCTReadTypes("""
struct S {
    var a: Int { 0 }
    var b: Int = 0 {
        willSet {}
        didSet {}
    }
    var c: Int {
        get { 0 }
    }
"""
        )

        let s = try XCTUnwrap(result.types[safe: 0]?.struct)

        XCTAssertEqual(s.storedProperties.count, 1)

        let b = try XCTUnwrap(s.storedProperties[safe: 0])
        XCTAssertEqual(b.name, "b")
        XCTAssertEqual(b.type.name, "Int")
    }
}
