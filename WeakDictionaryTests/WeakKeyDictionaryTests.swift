//
//  WeakKeyDictionaryTests.swift
//  WeakDictionary
//
//  Created by Nicholas Cross on 20/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import XCTest
@testable import WeakDictionary

class WeakKeyDictionaryTests: XCTestCase {

    private var weakDictionary: WeakKeyDictionary<ExampleKey, ExampleValue>!

    override func setUp() {
        super.setUp()

        weakDictionary = WeakKeyDictionary<ExampleKey, ExampleValue>()
    }

    func testAssignment() {
        var referencingKey: ExampleKey? = ExampleKey(name: "Left")
        var referencedValue: ExampleValue? = ExampleValue()

        autoreleasepool {
            weakDictionary[referencingKey!] = referencedValue
            XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a reference")

            XCTAssertNotNil(weakDictionary[referencingKey!], "Expected key to have a value")
            referencedValue = nil
        }

        XCTAssertEqual(weakDictionary.count, 0, "Expected to be left holding an empty reference")

        weak var accessValue = weakDictionary[ExampleKey(name: "Left")]
        XCTAssertNil(accessValue, "Expected key to have no value")

        weakDictionary[ExampleKey(name: "Left")] = nil
        XCTAssertEqual(weakDictionary.count, 0, "Expected to be left holding no references")

        autoreleasepool {
            referencingKey = ExampleKey(name: "Right")
            referencedValue = ExampleValue()
            weakDictionary[referencingKey!] = referencedValue
            XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a reference")

            accessValue = weakDictionary[ExampleKey(name: "Right")]
            XCTAssertNotNil(accessValue, "Expected key to have a accessible value")

            referencingKey = nil
        }
        XCTAssertEqual(weakDictionary.count, 0, "Expected to be left holding no references")

        accessValue = weakDictionary[ExampleKey(name: "Right")]
        XCTAssertNil(accessValue, "Expected key to have no accessible value")

        weakDictionary[ExampleKey(name: "Right")] = nil
        XCTAssertEqual(weakDictionary.count, 0, "Expected to be left holding no references")

        weakDictionary[ExampleKey(name: "Fleeting")] = ExampleValue()
        XCTAssertEqual(weakDictionary.count, 0, "Expected to be left holding no references")
    }

    func testKeyReaping() {
        var transientKey: ExampleKey? = ExampleKey(name: "Left")
        let referencedValue: ExampleValue = ExampleValue()
        weakDictionary[transientKey!] = referencedValue
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding an empty reference")

        var reaped = weakDictionary.weakKeyDictionary()
        XCTAssertEqual(reaped.count, 1, "Expected to be left holding a single reference")

        transientKey = nil
        reaped = weakDictionary.weakKeyDictionary()
        XCTAssertEqual(reaped.count, 0, "Expected to be left holding no references")

        reaped[ExampleKey(name: "Fleeting")] = ExampleValue()
        reaped[ExampleKey(name: "Fleeting1")] = ExampleValue()
        reaped[ExampleKey(name: "Fleeting2")] = ExampleValue()
        reaped[ExampleKey(name: "Fleeting3")] = ExampleValue()
        reaped[ExampleKey(name: "Fleeting4")] = ExampleValue()
        reaped = reaped.weakKeyDictionary()
        XCTAssertEqual(reaped.count, 0, "Expected to be left holding nil references")
    }

    func testValueReaping() {
        autoreleasepool {
            let retainedKey: ExampleKey = ExampleKey(name: "Left")
            let transientValue: ExampleValue? = ExampleValue()
            weakDictionary[retainedKey] = transientValue
            XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding an empty reference")

            let reaped = weakDictionary.weakKeyDictionary()
            XCTAssertEqual(reaped.count, 1, "Expected to be left holding a single reference")
        }

        let reaped = weakDictionary.weakKeyDictionary()
        XCTAssertEqual(reaped.count, 0, "Expected to be left holding no references")
    }

    func testMutatingReap() {
        autoreleasepool {
            let transientKey: ExampleKey? = ExampleKey(name: "Left")
            let retainedValue: ExampleValue = ExampleValue()
            weakDictionary[transientKey!] = retainedValue
            XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a single reference")
        }
        XCTAssertEqual(weakDictionary.count, 0, "Expected nil references to be reaped")

        weakDictionary[ExampleKey(name: "Fleeting")] = ExampleValue()
        weakDictionary[ExampleKey(name: "Fleeting1")] = ExampleValue()
        weakDictionary[ExampleKey(name: "Fleeting2")] = ExampleValue()
        weakDictionary[ExampleKey(name: "Fleeting3")] = ExampleValue()
        weakDictionary[ExampleKey(name: "Fleeting4")] = ExampleValue()
        XCTAssertEqual(weakDictionary.count, 0, "Expected nil references to be reaped")
    }

    func testStrongification() {
        let retainedKey: ExampleKey = ExampleKey(name: "Left")
        var transientValue: ExampleValue? = ExampleValue()

        var reaped: WeakKeyDictionary<ExampleKey, ExampleValue>!
        var strongDictionary: [ExampleKey: ExampleValue]!

        autoreleasepool {
            weakDictionary[retainedKey] = transientValue
            XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")

            reaped = weakDictionary.weakKeyDictionary()
            XCTAssertEqual(reaped.count, 1, "Expected to be left holding a single reference")
        }

        autoreleasepool {
            strongDictionary = weakDictionary.dictionary()
            XCTAssert(strongDictionary?.count == 1, "Expected to be holding a single key value pair")

            transientValue = nil
        }

        autoreleasepool {
            reaped = weakDictionary.weakKeyDictionary()
            XCTAssertEqual(reaped.count, 1, "Expected to be left holding a single reference")

            weak var weakExample: ExampleValue? = strongDictionary?[retainedKey]
            XCTAssertNotNil(weakExample, "Expected to find Example in strong dictionary")
        }

        reaped = weakDictionary.weakKeyDictionary()
        XCTAssertEqual(reaped.count, 0, "Expected unreferenced values to be released")

        autoreleasepool {
            transientValue = ExampleValue()
            weakDictionary[retainedKey] = transientValue
            transientValue = nil
        }
        XCTAssertEqual(weakDictionary.count, 0, "Expected to be holding no references")
        XCTAssertEqual(weakDictionary.dictionary().count, 0, "Expected empty references to be ignored")
    }

    func testInitWithDictionary() {
        let retainedKey = ExampleKey(name: "Left")
        var accessValue: ExampleValue!

        autoreleasepool {
            let strongDict = [
                retainedKey: ExampleValue(),
                ExampleKey(name: "Right"): ExampleValue()
            ]

            weakDictionary = WeakKeyDictionary<ExampleKey, ExampleValue>(dictionary: strongDict)
            XCTAssert(weakDictionary.count == 2, "Expected dictionary to be initialised with two references")

            accessValue = weakDictionary[retainedKey]
            XCTAssertNotNil(accessValue, "Expected value to be available for key")
        }

        XCTAssertNotNil(weakDictionary[retainedKey])
        XCTAssertEqual(weakDictionary.count, 1, "Expected nullified weak references to be reaped")
    }

    func testConversionFromWeakKeyDictionaryToDictionary() {
        let retainedKey = ExampleKey(name: "Left")
        let dictionary: [ExampleKey: ExampleValue] = [
            retainedKey: ExampleValue(),
            ExampleKey(name: "Right"): ExampleValue()
        ]

        let weakKeyDictionary = dictionary.weakKeyDictionary()
        let convertedDictionary = weakKeyDictionary.dictionary()
        XCTAssertEqual(dictionary.keys, convertedDictionary.keys, "Expect dictionaries to match")
    }

    func testConversionFromWeakKeyDictionaryToWeakKeyDictionary() {
        let retainedKey = ExampleKey(name: "Left")
        let dictionary: [ExampleKey: ExampleValue] = [
            retainedKey: ExampleValue(),
            ExampleKey(name: "Right"): ExampleValue()
        ]

        let weakKeyDictionary = dictionary.weakKeyDictionary()
        let convertedDictionary = weakKeyDictionary.weakKeyDictionary().dictionary()
        XCTAssertEqual(dictionary.keys, convertedDictionary.keys, "Expect dictionaries to match")
    }

    func testConversionFromWeakKeyDictionaryToWeakDictionary() {
        let retainedKey = ExampleKey(name: "Left")
        let dictionary: [ExampleKey: ExampleValue] = [
            retainedKey: ExampleValue(),
            ExampleKey(name: "Right"): ExampleValue()
        ]

        let weakKeyDictionary = dictionary.weakKeyDictionary()
        let convertedDictionary = weakKeyDictionary.weakDictionary().dictionary()
        XCTAssertEqual(dictionary.keys, convertedDictionary.keys, "Expect dictionaries to match")
    }

    func testConversionFromWeakDictionaryToWeakKeyDictionary() {
        let retainedKey = ExampleKey(name: "Left")
        let dictionary: [ExampleKey: ExampleValue] = [
            retainedKey: ExampleValue(),
            ExampleKey(name: "Right"): ExampleValue()
        ]

        let weakDictionary = dictionary.weakKeyDictionary().weakDictionary()
        let convertedDictionary = weakDictionary.weakKeyDictionary().dictionary()
        XCTAssertEqual(dictionary.keys, convertedDictionary.keys, "Expect dictionaries to match")
    }

    private func createTestData() -> (Int, [ExampleKey]) {
        let iterations = 10000

        var keys = [ExampleKey]()
        for index in 0..<iterations {
            keys.append(ExampleKey(name: "Example1 \(index)"))
        }

        return (iterations, keys)
    }

    func testBaseLineAssignPerformance() {
        let (iterations, baselineKeys) = createTestData()

        var baseline = [ExampleKey: ExampleKey]()
        measure {
            for index in 0..<iterations {
                baseline[baselineKeys[index]] = ExampleKey(name: "asdf")
            }
        }
    }

    func testWeakDictionaryAssignPerformance() {
        let (iterations, keys) = createTestData()

        var weakDict = WeakDictionary<ExampleKey, ExampleKey>()
        measure {
            for index in 0..<iterations {
                weakDict[keys[index]] = ExampleKey(name: "asdf")
            }
        }
    }

    func testWeakKeyDictionaryAssignPerformance() {
        let (iterations, keys) = createTestData()

        var weakDict = WeakKeyDictionary<ExampleKey, ExampleKey>()
        measure {
            for index in 0..<iterations {
                weakDict[keys[index]] = ExampleKey(name: "asdf")
            }
        }
    }

    func testBaseLineLookUpPerformance() {
        let (iterations, baselineKeys) = createTestData()

        var baseline = [ExampleKey: ExampleKey]()
        for index in 0..<iterations {
            baseline[baselineKeys[index]] = ExampleKey(name: "asdf")
        }

        measure {
            for index in 0..<iterations {
                _ = baseline[baselineKeys[index]]
            }
        }
    }

    func testWeakDictionaryLookUpPerformance() {
        let (iterations, baselineKeys) = createTestData()

        var baseline = WeakDictionary<ExampleKey, ExampleKey>()
        for index in 0..<iterations {
            baseline[baselineKeys[index]] = ExampleKey(name: "asdf")
        }

        measure {
            for index in 0..<iterations {
                _ = baseline[baselineKeys[index]]
            }
        }
    }

    func testWeakKeyDictionaryLookUpPerformance() {
        let (iterations, baselineKeys) = createTestData()

        var baseline = WeakKeyDictionary<ExampleKey, ExampleKey>()
        for index in 0..<iterations {
            baseline[baselineKeys[index]] = ExampleKey(name: "asdf")
        }

        measure {
            for index in 0..<iterations {
                _ = baseline[baselineKeys[index]]
            }
        }
    }
}

private class ExampleValue {

}

private class ExampleKey: Hashable {
    let value: String

    init(name: String) {
        value = name
    }

    public static func == (lhs: ExampleKey, rhs: ExampleKey) -> Bool {
        return lhs.value == rhs.value
    }

    public var hashValue: Int {
        return value.hash
    }
}
