//
//  WeakKeyRetainsValueTests.swift
//  WeakDictionary
//
//  Created by Nicholas Cross on 29/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//
import XCTest
@testable import WeakDictionary

private class Sock {
    
}

class WeakKeyRetainsValuesTests: XCTestCase {
    
    private var weakDictionary: WeakKeyDictionary<Foot, Sock>!
    
    override func setUp() {
        super.setUp()
        
        weakDictionary = WeakKeyDictionary<Foot, Sock>(withValuesRetainedByKey: true)
    }
    
    func testAssignmentWithValuesRetainedByKey() {
        var f: Foot? = Foot(name: "Left")
        var s: Sock? = Sock()
        weakDictionary[f!] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a reference \(weakDictionary.count)")
        
        weak var s1 = weakDictionary[f!]
        XCTAssert(s1 != nil, "Expected key to have a value")
        
        s = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a reference \(weakDictionary.count)")
        
        weak var s2 = weakDictionary[Foot(name: "Left")]
        XCTAssert(s2 != nil, "Expected key to have a value because it is retained by the key")
        
        weakDictionary.reap()
        XCTAssert(s2 != nil, "Expected value to exist because it is retained by the key reference")
        
        f = nil
        weak var s3 = weakDictionary[Foot(name: "Left")]
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        XCTAssert(s3 == nil, "Expected key to no longer have a value because the key no longer retains it")
        XCTAssert(s2 != nil, "Expected value to exist because it is retained by the key reference")
        
        weakDictionary.reap()
        XCTAssert(s2 == nil, "Expected value to be nullified because it is no longer retained by the key reference")
    }
    
}
    
