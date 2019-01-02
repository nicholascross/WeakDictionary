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
        var s: Example? = Example()
        weakDictionary["avalue"] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a reference \(weakDictionary.count)")

        weak var s1 = weakDictionary["avalue"]
        XCTAssert(s1 != nil, "Expected avalue to have a value")

        s = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")

        weak var s2 = weakDictionary["avalue"]
        XCTAssert(s2 == nil, "Expected avalue to have no value")

        weakDictionary["avalue"] = nil
        XCTAssert(weakDictionary.count == 0, "Expected to be left holding no references \(weakDictionary.count)")
    }

    func testReaping() {
        var s: Example? = Example()
        weakDictionary["avalue"] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")

        var reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")

        s = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 0, "Expected to be left holding no references \(reaped.count)")
    }

    func testMutatingReap() {
        var s: Example? = Example()
        weakDictionary["avalue"] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")

        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a single reference \(weakDictionary.count)")

        s = nil
        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 0, "Expected to be left holding no references \(weakDictionary.count)")
    }

    func testStrongification() {
        var s: Example? = Example()
        weakDictionary["avalue"] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")

        var reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")

        var strongDictionary: [String: Example]? = weakDictionary.toStrongDictionary()
        XCTAssert(strongDictionary?.count == 1, "Expected to be holding a single key value pair")

        s = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")

        weak var weakSock: Example? = strongDictionary?["avalue"]
        XCTAssert(weakSock != nil, "Expected to find sock in strong dictionary")

        strongDictionary = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 0, "Expected unreferenced values to be released \(reaped.count)")

        s = Example()
        weakDictionary["avalue"] = s
        s = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be holding an empty value reference")
        XCTAssert(weakDictionary.toStrongDictionary().count == 0, "Expected empty references to be ignored")
    }

    func testInitWithDictionary() {
        var strongDict: [String: Example]? = [
            "Left": Example(),
            "Right": Example()
        ]

        weakDictionary = WeakDictionary<String, Example>(dictionary: strongDict!)
        XCTAssert(weakDictionary.count == 2, "Expected dictionary to be initialised with two references")

        let s = weakDictionary["Left"]
        XCTAssert(s != nil, "Expected value to be available for key")

        strongDict = nil
        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 1, "Expected nullified weak references to be reaped")
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
