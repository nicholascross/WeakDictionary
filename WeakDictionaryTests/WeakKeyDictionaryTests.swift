//
//  WeakKeyDictionaryTests.swift
//  WeakDictionary
//
//  Created by Nicholas Cross on 20/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import XCTest
@testable import WeakDictionary

private class Sock {
    
}

class WeakKeyDictionaryTests: XCTestCase {
    
    private var weakDictionary: WeakKeyDictionary<Foot, Sock>!
    
    override func setUp() {
        super.setUp()
        
        weakDictionary = WeakKeyDictionary<Foot, Sock>()
    }
    
    func testAssignment() {
        var f: Foot? = Foot(name: "Left")
        var s: Sock? = Sock()
        weakDictionary[f!] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a reference \(weakDictionary.count)")
        
        weak var s1 = weakDictionary[f!]
        XCTAssert(s1 != nil, "Expected avalue to have a value")
        
        f = nil
        s = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        weak var s2 = weakDictionary[Foot(name: "Left")]
        XCTAssert(s2 == nil, "Expected avalue to have no value")
        
        weakDictionary[Foot(name: "Left")] = nil
        XCTAssert(weakDictionary.count == 0, "Expected to be left holding no references \(weakDictionary.count)")
    }
    
    func testKeyReaping() {
        var f: Foot? = Foot(name: "Left")
        let s: Sock = Sock()
        weakDictionary[f!] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        var reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")
        
        f = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 0, "Expected to be left holding no references \(reaped.count)")
    }
    
    func testValueReaping() {
        let f: Foot = Foot(name: "Left")
        var s: Sock? = Sock()
        weakDictionary[f] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        var reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")
        
        s = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 0, "Expected to be left holding no references \(reaped.count)")
    }
    
}

class Foot : Identifiable {
    typealias Identity = String
    
    let footName : String
    
    init(name: String) {
        footName = name
    }
    
    func identifier() -> Identity {
        return footName
    }
}
