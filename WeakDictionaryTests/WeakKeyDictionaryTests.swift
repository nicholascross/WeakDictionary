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
    
    private class Example {
        
    }
    
    private class Example1 : Hashable {
        let value : String
        
        init(name: String) {
            value = name
        }
        
        public static func ==(lhs: Example1, rhs: Example1) -> Bool {
            return lhs.value == rhs.value
        }
        
        public var hashValue: Int {
            return value.hash
        }
    }
    
    private var weakDictionary: WeakKeyDictionary<Example1, Example>!
    
    override func setUp() {
        super.setUp()
        
        weakDictionary = WeakKeyDictionary<Example1, Example>()
    }
    
    func testAssignment() {
        var f: Example1? = Example1(name: "Left")
        var s: Example? = Example()
        weakDictionary[f!] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a reference \(weakDictionary.count)")
        
        weak var s1 = weakDictionary[f!]
        XCTAssert(s1 != nil, "Expected key to have a value")
        
        s = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        weak var s2 = weakDictionary[Example1(name: "Left")]
        XCTAssert(s2 == nil, "Expected key to have no value")
        
        weakDictionary[Example1(name: "Left")] = nil
        XCTAssert(weakDictionary.count == 0, "Expected to be left holding no references \(weakDictionary.count)")
        
        f = Example1(name: "Right")
        s = Example()
        weakDictionary[f!] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a reference \(weakDictionary.count)")
        
        s2 = weakDictionary[Example1(name: "Right")]
        XCTAssert(s2 != nil, "Expected key to have a accessible value")
        
        f = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a nil reference \(weakDictionary.count)")
        
        s2 = weakDictionary[Example1(name: "Right")]
        XCTAssert(s2 == nil, "Expected key to have no accessible value")
        
        weakDictionary[Example1(name: "Right")] = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a nil reference \(weakDictionary.count)")
        
        weakDictionary[Example1(name: "Fleeting")] = Example()
        weakDictionary[Example1(name: "Fleeting1")] = Example()
        XCTAssert(weakDictionary.count == 3, "Expected to be left holding nil references \(weakDictionary.count)")
    }
    
    func testKeyReaping() {
        var f: Example1? = Example1(name: "Left")
        let s: Example = Example()
        weakDictionary[f!] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        var reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")
        
        f = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 0, "Expected to be left holding no references \(reaped.count)")
        
        reaped[Example1(name: "Fleeting")] = Example()
        reaped[Example1(name: "Fleeting1")] = Example()
        reaped[Example1(name: "Fleeting2")] = Example()
        reaped[Example1(name: "Fleeting3")] = Example()
        reaped[Example1(name: "Fleeting4")] = Example()
        reaped = reaped.reapedDictionary()
        XCTAssert(reaped.count == 0, "Expected to be left holding nil references \(weakDictionary.count)")
    }
    
    func testValueReaping() {
        let f: Example1 = Example1(name: "Left")
        var s: Example? = Example()
        weakDictionary[f] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        var reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")
        
        s = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 0, "Expected to be left holding no references \(reaped.count)")
    }
    
    func testMutatingReap() {
        var f: Example1? = Example1(name: "Left")
        let s: Example = Example()
        weakDictionary[f!] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a single reference \(weakDictionary.count)")
        
        f = nil
        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 0, "Expected to be left holding no references \(weakDictionary.count)")
        
        weakDictionary[Example1(name: "Fleeting")] = Example()
        weakDictionary[Example1(name: "Fleeting1")] = Example()
        weakDictionary[Example1(name: "Fleeting2")] = Example()
        weakDictionary[Example1(name: "Fleeting3")] = Example()
        weakDictionary[Example1(name: "Fleeting4")] = Example()
        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 0, "Expected to be left holding nil references \(weakDictionary.count)")
    }
    
    func testStrongification() {
        let f: Example1 = Example1(name: "Left")
        var s: Example? = Example()
        weakDictionary[f] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        var reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")
        
        var strongDictionary: [Example1: Example]? = weakDictionary.toStrongDictionary()
        XCTAssert(strongDictionary?.count == 1, "Expected to be holding a single key value pair")
        
        s = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")
        
        weak var weakExample: Example? = strongDictionary?[f]
        XCTAssert(weakExample != nil, "Expected to find Example in strong dictionary")
        
        strongDictionary = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 0, "Expected unreferenced values to be released \(reaped.count)")
        
        s = Example()
        weakDictionary[f] = s
        s = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be holding an empty value reference")
        XCTAssert(weakDictionary.toStrongDictionary().count == 0, "Expected empty references to be ignored")
    }
    
    func testInitWithDictionary() {
        let f = Example1(name: "Left")
        var strongDict: [Example1:Example]? = [
            f : Example(),
            Example1(name: "Right") : Example()
        ]
        
        weakDictionary = WeakKeyDictionary<Example1, Example>(dictionary: strongDict!)
        XCTAssert(weakDictionary.count == 2, "Expected dictionary to be initialised with two references")
        
        let s = weakDictionary[f]
        XCTAssert(s != nil,"Expected value to be available for key")
        
        strongDict = nil
        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 1, "Expected nullified weak references to be reaped")
    }
    
    func testReadmeExample() {
        var dictionary = WeakKeyDictionary<Example1, Example>()
        var f: Example1 = Example1(name: "value")
        let s: Example? = Example()
        dictionary[f] = s
        print("\(dictionary[f] != nil ? "an example exits" : "no example exits")")
        //prints: an example exits
        
        f = Example1(name: "anothervalue")
        let e = Example1(name: "value")
        print("\(dictionary[e] != nil ? "an example exits" : "no example exits")")
        //prints: no example exits
        
        print("number of item in dictionary \(dictionary.count)")
        //prints: number of item in dictionary 1
        //This is because nil key/value references are not automatically nullified when the key or value is deallocated
        
        print("number of item in reaped dictionary \(dictionary.reapedDictionary().count)")
        //prints: number of item in reaped dictionary 0
        //Reaping the dictionary removes any keys without values and values not referenced by any key
    }
    
    private func createTestData() -> (Int, [Example1]) {
        let iterations = 10000
        
        var keys = [Example1]()
        for i in 0..<iterations {
            keys.append(Example1(name: "Example1 \(i)"))
        }
        
        return (iterations, keys)
    }
    
    func testBaseLineAssignPerformance() {
        let (iterations, baselineKeys) = createTestData()
        
        var baseline = [Example1: Example1]()
        measure {
            for i in 0..<iterations {
                baseline[baselineKeys[i]] = Example1(name:"asdf")
            }
        }
    }
    
    func testWeakDictionaryAssignPerformance() {
        let (iterations, keys) = createTestData()
        
        var weakDict = WeakDictionary<Example1, Example1>()
        measure {
            for i in 0..<iterations {
                weakDict[keys[i]] = Example1(name:"asdf")
            }
        }
    }
    
    func testWeakKeyDictionaryAssignPerformance() {
        let (iterations, keys) = createTestData()
        
        var weakDict = WeakKeyDictionary<Example1, Example1>()
        measure {
            for i in 0..<iterations {
                weakDict[keys[i]] = Example1(name:"asdf")
            }
        }
    }
    
    func testBaseLineLookUpPerformance() {
        let (iterations, baselineKeys) = createTestData()
        
        var baseline = [Example1: Example1]()
        for i in 0..<iterations {
            baseline[baselineKeys[i]] = Example1(name:"asdf")
        }
        
        measure {
            for i in 0..<iterations {
                let _ = baseline[baselineKeys[i]]
            }
        }
    }
    
    
    func testWeakDictionaryLookUpPerformance() {
        let (iterations, baselineKeys) = createTestData()
        
        var baseline = WeakDictionary<Example1,Example1>()
        for i in 0..<iterations {
            baseline[baselineKeys[i]] = Example1(name:"asdf")
        }
        
        measure {
            for i in 0..<iterations {
                let _ = baseline[baselineKeys[i]]
            }
        }
    }
    
    
    func testWeakKeyDictionaryLookUpPerformance() {
        let (iterations, baselineKeys) = createTestData()
        
        var baseline = WeakKeyDictionary<Example1,Example1>()
        for i in 0..<iterations {
            baseline[baselineKeys[i]] = Example1(name:"asdf")
        }
        
        measure {
            for i in 0..<iterations {
                let _ = baseline[baselineKeys[i]]
            }
        }
    }
}
