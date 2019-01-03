//
//  DocumentationTests.swift
//  WeakDictionary
//
//  Created by Nicholas Cross on 3/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import XCTest
@testable import WeakDictionary

class DocumentationTests: XCTestCase {

    func testWeakReadmeExample() {
        var dictionary = WeakDictionary<String, ExampleValue>()
        var value: ExampleValue? = ExampleValue()
        dictionary["key"] = value

        print("\(dictionary["key"] != nil ? "has value" : "value missing")")
        //prints: has value

        value = nil
        print("\(dictionary["key"] != nil ? "has value" : "value missing")")
        //prints: value missing
    }

    func testWeakKeyReadmeExample() {
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

        print("number of item in reaped dictionary \(dictionary.weakKeyDictionary().count)")
        //prints: number of item in reaped dictionary 0
        //Reaping the dictionary removes any keys without values and values not referenced by any key
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
