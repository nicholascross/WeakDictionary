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
        weakDictionary[referencingKey!] = referencedValue
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a reference")

        XCTAssertNotNil(weakDictionary[referencingKey!], "Expected key to have a value")

        referencedValue = nil
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding an empty reference")

        weak var accessValue = weakDictionary[ExampleKey(name: "Left")]
        XCTAssertNil(accessValue, "Expected key to have no value")

        weakDictionary[ExampleKey(name: "Left")] = nil
        XCTAssertEqual(weakDictionary.count, 0, "Expected to be left holding no references")

        referencingKey = ExampleKey(name: "Right")
        referencedValue = ExampleValue()
        weakDictionary[referencingKey!] = referencedValue
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a reference")

        accessValue = weakDictionary[ExampleKey(name: "Right")]
        XCTAssertNotNil(accessValue, "Expected key to have a accessible value")

        referencingKey = nil
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a nil reference")

        accessValue = weakDictionary[ExampleKey(name: "Right")]
        XCTAssertNil(accessValue, "Expected key to have no accessible value")

        weakDictionary[ExampleKey(name: "Right")] = nil
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a nil reference")

        weakDictionary[ExampleKey(name: "Fleeting")] = ExampleValue()
        XCTAssertEqual(weakDictionary.count, 2, "Expected to be left holding another nil reference")
    }

    func testKeyReaping() {
        var transientKey: ExampleKey? = ExampleKey(name: "Left")
        let referencedValue: ExampleValue = ExampleValue()
        weakDictionary[transientKey!] = referencedValue
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding an empty reference")

        var reaped = weakDictionary.reapedDictionary()
        XCTAssertEqual(reaped.count, 1, "Expected to be left holding a single reference")

        transientKey = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssertEqual(reaped.count, 0, "Expected to be left holding no references")

        reaped[ExampleKey(name: "Fleeting")] = ExampleValue()
        reaped[ExampleKey(name: "Fleeting1")] = ExampleValue()
        reaped[ExampleKey(name: "Fleeting2")] = ExampleValue()
        reaped[ExampleKey(name: "Fleeting3")] = ExampleValue()
        reaped[ExampleKey(name: "Fleeting4")] = ExampleValue()
        reaped = reaped.reapedDictionary()
        XCTAssertEqual(reaped.count, 0, "Expected to be left holding nil references")
    }

    func testValueReaping() {
        let retainedKey: ExampleKey = ExampleKey(name: "Left")
        var transientValue: ExampleValue? = ExampleValue()
        weakDictionary[retainedKey] = transientValue
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding an empty reference")

        var reaped = weakDictionary.reapedDictionary()
        XCTAssertEqual(reaped.count, 1, "Expected to be left holding a single reference")

        transientValue = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssertEqual(reaped.count, 0, "Expected to be left holding no references")
    }

    func testMutatingReap() {
        var transientKey: ExampleKey? = ExampleKey(name: "Left")
        let retainedValue: ExampleValue = ExampleValue()
        weakDictionary[transientKey!] = retainedValue
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding an empty reference")

        weakDictionary.reap()
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a single reference")

        transientKey = nil
        weakDictionary.reap()
        XCTAssertEqual(weakDictionary.count, 0, "Expected nil references to be reaped")

        weakDictionary[ExampleKey(name: "Fleeting")] = ExampleValue()
        weakDictionary[ExampleKey(name: "Fleeting1")] = ExampleValue()
        weakDictionary[ExampleKey(name: "Fleeting2")] = ExampleValue()
        weakDictionary[ExampleKey(name: "Fleeting3")] = ExampleValue()
        weakDictionary[ExampleKey(name: "Fleeting4")] = ExampleValue()
        XCTAssertEqual(weakDictionary.count, 5, "Expected to be left holding nil references")
        weakDictionary.reap()
        XCTAssertEqual(weakDictionary.count, 0, "Expected nil references to be reaped")
    }

    func testStrongification() {
        let retainedKey: ExampleKey = ExampleKey(name: "Left")
        var transientValue: ExampleValue? = ExampleValue()
        weakDictionary[retainedKey] = transientValue
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")

        var reaped = weakDictionary.reapedDictionary()
        XCTAssertEqual(reaped.count, 1, "Expected to be left holding a single reference")

        var strongDictionary: [ExampleKey: ExampleValue]? = weakDictionary.toStrongDictionary()
        XCTAssert(strongDictionary?.count == 1, "Expected to be holding a single key value pair")

        transientValue = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssertEqual(reaped.count, 1, "Expected to be left holding a single reference")

        weak var weakExample: ExampleValue? = strongDictionary?[retainedKey]
        XCTAssertNotNil(weakExample, "Expected to find Example in strong dictionary")

        strongDictionary = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssertEqual(reaped.count, 0, "Expected unreferenced values to be released")

        transientValue = ExampleValue()
        weakDictionary[retainedKey] = transientValue
        transientValue = nil
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be holding an empty value reference")
        XCTAssertEqual(weakDictionary.toStrongDictionary().count, 0, "Expected empty references to be ignored")
    }

    func testInitWithDictionary() {
        let retainedKey = ExampleKey(name: "Left")
        var strongDict: [ExampleKey: ExampleValue]? = [
            retainedKey: ExampleValue(),
            ExampleKey(name: "Right"): ExampleValue()
        ]

        weakDictionary = WeakKeyDictionary<ExampleKey, ExampleValue>(dictionary: strongDict!)
        XCTAssert(weakDictionary.count == 2, "Expected dictionary to be initialised with two references")

        let accessValue = weakDictionary[retainedKey]
        XCTAssertNotNil(accessValue, "Expected value to be available for key")

        strongDict = nil
        weakDictionary.reap()
        XCTAssertEqual(weakDictionary.count, 1, "Expected nullified weak references to be reaped")
    }

    func testReadmeExample() {
        var dictionary = WeakKeyDictionary<ExampleKey, ExampleValue>()
        var transientKey: ExampleKey = ExampleKey(name: "value")
        let retainedValue: ExampleValue? = ExampleValue()
        dictionary[transientKey] = retainedValue
        print("\(dictionary[transientKey] != nil ? "an example exits" : "no example exits")")
        //prints: an example exits

        transientKey = ExampleKey(name: "anothervalue")
        let oldKey = ExampleKey(name: "value")
        print("\(dictionary[oldKey] != nil ? "an example exits" : "no example exits")")
        //prints: no example exits

        print("number of item in dictionary \(dictionary.count)")
        //prints: number of item in dictionary 1
        //This is because nil key/value references are not automatically nullified when the key or value is deallocated

        print("number of item in reaped dictionary \(dictionary.reapedDictionary().count)")
        //prints: number of item in reaped dictionary 0
        //Reaping the dictionary removes any keys without values and values not referenced by any key
    }

    private func createTestData() -> (Int, [ExampleKey]) {
        let iterations = 50000

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
