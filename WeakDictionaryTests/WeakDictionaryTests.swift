//
//  WeakDictionaryTests.swift
//  WeakDictionaryTests
//
//  Created by Nicholas Cross on 19/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import XCTest
@testable import WeakDictionary

private class Sock {
    
}


class WeakDictionaryTests: XCTestCase {
    
    private var weakDictionary: WeakDictionary<String, Sock>!
    
    override func setUp() {
        super.setUp()
        
        weakDictionary = WeakDictionary<String, Sock>()
    }
    
    func testAssignment() {
        var s: Sock? = Sock()
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
        var s: Sock? = Sock()
        weakDictionary["avalue"] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        var reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")
        
        s = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 0, "Expected to be left holding no references \(reaped.count)")
    }
    
    func testMutatingReap() {
        var s: Sock? = Sock()
        weakDictionary["avalue"] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")

        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a single reference \(weakDictionary.count)")
        
        s = nil
        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 0, "Expected to be left holding no references \(weakDictionary.count)")
    }
    
    func testReadmeExample() {
        class Shoe {
            
        }
        
        var dictionary = WeakDictionary<String, Shoe>()
        var shoe: Shoe? = Shoe()
        dictionary["foot"] = shoe
        
        print("foot has \(dictionary["foot"] != nil ? "a shoe" : "no shoe")")
        //prints: foot has a shoe
        
        shoe = nil
        print("foot has \(dictionary["foot"] != nil ? "a shoe" : "no shoe!")")
        //prints: foot has no shoe!
    }
}
