//
//  WeakDictionaryTests.swift
//  WeakDictionaryTests
//
//  Created by Nicholas Cross on 19/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import XCTest
@testable import WeakDictionary

private class Example {

}

class WeakDictionaryTests: XCTestCase {

    private var weakDictionary: WeakDictionary<String, Example>!

    override func setUp() {
        super.setUp()

        weakDictionary = WeakDictionary<String, Example>()
    }

    func testAssignment() {
        let retainedKey = "avalue"
        var transientValue: Example? = Example()
        weakDictionary[retainedKey] = transientValue
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a reference")

        XCTAssertNotNil(weakDictionary[retainedKey], "Expected avalue to have a value")

        transientValue = nil
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding an empty reference")

        XCTAssertNil(weakDictionary[retainedKey], "Expected avalue to have no value")

        weakDictionary[retainedKey] = nil
        XCTAssertEqual(weakDictionary.count, 0, "Expected to be left holding no references")
    }

    func testReaping() {
        var transientValue: Example? = Example()
        weakDictionary["avalue"] = transientValue
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding an empty reference")

        var reaped = weakDictionary.weakDictionary()
        XCTAssertEqual(reaped.count, 1, "Expected to be left holding a single reference")

        transientValue = nil
        reaped = weakDictionary.weakDictionary()
        XCTAssertEqual(reaped.count, 0, "Expected to be left holding no references")
    }

    func testMutatingReap() {
        var transientValue: Example? = Example()
        weakDictionary["avalue"] = transientValue
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a single reference")

        weakDictionary.reap()
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a single reference")

        transientValue = nil
        weakDictionary.reap()
        XCTAssertEqual(weakDictionary.count, 0, "Expected to be left holding no references")
    }

    func testStrongification() {
        var transientValue: Example? = Example()
        weakDictionary["avalue"] = transientValue
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding an empty reference")

        var reaped = weakDictionary.weakDictionary()
        XCTAssertEqual(reaped.count, 1, "Expected to be left holding a single reference")

        var strongDictionary: [String: Example]? = weakDictionary.dictionary()
        XCTAssert(strongDictionary?.count == 1, "Expected to be holding a single key value pair")

        transientValue = nil
        reaped = weakDictionary.weakDictionary()
        XCTAssertEqual(reaped.count, 1, "Expected to be left holding a single reference \(reaped.count)")

        weak var weakSock: Example? = strongDictionary?["avalue"]
        XCTAssertNotNil(weakSock, "Expected to find sock in strong dictionary")

        strongDictionary = nil
        reaped = weakDictionary.weakDictionary()
        XCTAssertEqual(reaped.count, 0, "Expected unreferenced values to be released")

        transientValue = Example()
        weakDictionary["avalue"] = transientValue
        transientValue = nil
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be holding an empty value reference")
        XCTAssertEqual(weakDictionary.dictionary().count, 0, "Expected empty references to be ignored")
    }

    func testInitWithDictionary() {
        var dictionary: [String: Example]? = [
            "Left": Example(),
            "Right": Example()
        ]

        weakDictionary = WeakDictionary<String, Example>(dictionary: dictionary!)
        XCTAssertEqual(weakDictionary.count, 2, "Expected dictionary to be initialised with two references")

        let accessValue = weakDictionary["Left"]
        XCTAssertNotNil(accessValue, "Expected value to be available for key")

        dictionary = nil
        weakDictionary.reap()
        XCTAssertEqual(weakDictionary.count, 1, "Expected nullified weak references to be reaped")
    }

    func testReadmeExample() {
        var dictionary = WeakDictionary<String, Example>()
        var value: Example? = Example()
        dictionary["key"] = value

        print("\(dictionary["key"] != nil ? "has value" : "value missing")")
        //prints: has value

        value = nil
        print("\(dictionary["key"] != nil ? "has value" : "value missing")")
        //prints: value missing
    }
}
