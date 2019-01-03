//
//  WeakKeyRetainsValueTests.swift
//  WeakDictionary
//
//  Created by Nicholas Cross on 29/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//
import XCTest
@testable import WeakDictionary

class WeakKeyRetainsValuesTests: XCTestCase {
    private var weakDictionary: WeakKeyDictionary<ExampleKey, ExampleValue>!

    override func setUp() {
        super.setUp()

        weakDictionary = WeakKeyDictionary<ExampleKey, ExampleValue>(valuesRetainedByKey: true)
    }

    func testAssignmentWithValuesRetainedByKey() {
        let accessingKey: ExampleKey = ExampleKey(name: "Left")
        var retainingKey: ExampleKey! = ExampleKey(name: "Left")
        var retainedValue: ExampleValue! = ExampleValue()
        weakDictionary[retainingKey!] = retainedValue
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a reference")

        weak var accessedValue = weakDictionary[retainingKey]
        XCTAssertNotNil(accessedValue, "Expected key to have a value")

        retainedValue = nil
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding a reference")

        weak var transientAccessValue = weakDictionary[accessingKey]
        XCTAssertNotNil(transientAccessValue, "Expected key to have a value because it is retained by the key")

        weakDictionary.reap()
        XCTAssertNotNil(transientAccessValue, "Expected value to exist because it is retained by the key reference")

        retainingKey = nil
        weak var absentAccessValue = weakDictionary[accessingKey]
        XCTAssertEqual(weakDictionary.count, 1, "Expected to be left holding an empty reference")
        XCTAssertNil(absentAccessValue, "Expected key to no longer have a value because the key no longer retains it")
        XCTAssertNotNil(transientAccessValue, "Expected value to exist because it is retained by the key reference")

        weakDictionary.reap()
        XCTAssertNil(transientAccessValue, "Expected value to be nil as it is no longer retained by the key reference")
    }

    func testInitFromDictionary() {
        var transientKey: ExampleKey! = ExampleKey(name: "Left")
        var transientValue: ExampleValue! = ExampleValue()
        var dictionary: [ExampleKey: ExampleValue]! = [
            transientKey: transientValue,
            ExampleKey(name: "Right"): ExampleValue()
        ]

        weakDictionary = WeakKeyDictionary<ExampleKey, ExampleValue>(dictionary: dictionary, valuesRetainedByKey: true)

        dictionary = nil
        weak var weaklyHeldValue: ExampleValue? = transientValue
        transientValue = nil

        XCTAssertNotNil(weakDictionary[ExampleKey(name: "Left")], "Expected value to be retained by key")
        XCTAssertNotNil(weaklyHeldValue, "Expected to be retained by key")

        transientKey = nil
        XCTAssertNil(weakDictionary[ExampleKey(name: "Left")], "Expected value to no longer be accessible by key")
        XCTAssertNotNil(weaklyHeldValue, "Expected to be retained by key container even though key is gone")

        weakDictionary.reap()
        XCTAssertNil(weaklyHeldValue, "Expected weakly held reference would be released after reaping")
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
