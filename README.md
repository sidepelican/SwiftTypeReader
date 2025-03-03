# SwiftTypeReader

You can gather type definitions from Swift source code.

## Example

```swift
            let reader = Reader()

            let source = """
struct S {
    var a: Int?
}
"""
            let result = try reader.read(source: source)

            let s = try XCTUnwrap(result.types[safe: 0]?.struct)
            XCTAssertEqual(s.name, "S")

            XCTAssertEqual(s.storedProperties.count, 1)
            let a = try XCTUnwrap(s.storedProperties[safe: 0])
            XCTAssertEqual(a.name, "a")

            let aType = try XCTUnwrap(a.type?.struct)
            XCTAssertEqual(aType.name, "Optional")
            XCTAssertEqual(aType.genericsArguments.count, 1)

            let aWrappedType = try XCTUnwrap(aType.genericsArguments[safe: 0]?.struct)
            XCTAssertEqual(aWrappedType.name, "Int")
```

# Development

## Run XCTest with Xcode

Set environment variable at scheme configuration to find SwiftSyntax runtime library.

```
DYLD_LIBRARY_PATH = /Applications/Xcode12.5.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx
```

## Design consideration

This library doesn't distinguish type descriptor and concrete type.
It make implementation simple but ugly especially when generic argument application happens.

# Unsupported language features

## Class

```swift
class C {}
```

## Inheritance clause

```swift
struct S: P {}
```

## Computed properties

```swift
struct S {
    var x: Int { 0 }
    var y: Int {
        get { _y }
        set { _y = newValue }
    }
    var _y: Int = 0
}
```

## Methods

```swift
struct S {
    func f() {}
}
```

## User defined generics

```swift
struct S<T> { }
```

## Variable without type annotation

```swift
struct S {
    var a = 0
}
```

## Function types

```swift
struct S {
    var f: () -> Void
}
```

## Stored properties of standard types

They are only defined with names.
