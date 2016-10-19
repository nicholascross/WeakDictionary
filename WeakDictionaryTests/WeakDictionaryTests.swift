//
//  WeakDictionaryTests.swift
//  WeakDictionaryTests
//
//  Created by Nicholas Cross on 19/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import XCTest
@testable import WeakDictionary

class Sock {
    
}


class WeakDictionaryTests: XCTestCase {
    
    var weakDictionary: WeakDictionary<String, Sock>!
    
    override func setUp() {
        super.setUp()
        
        weakDictionary = WeakDictionary<String, Sock>()
    }
    
    func testAssignment() {
        var s: Sock? = Sock()
        weakDictionary["avalue"] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        weak var s1 = weakDictionary["avalue"]
        XCTAssert(s1 != nil, "Expected avalue to have a value")
        
        s = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        weak var s2 = weakDictionary["avalue"]
        XCTAssert(s2 == nil, "Expected avalue to have no value")
        
        weakDictionary["avalue"] = nil
        XCTAssert(weakDictionary.count == 0, "Expected to be left holding no references \(weakDictionary.count)")
    }
    
}
