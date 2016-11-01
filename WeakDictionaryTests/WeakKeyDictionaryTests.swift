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
        XCTAssert(s1 != nil, "Expected key to have a value")
        
        s = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        weak var s2 = weakDictionary[Foot(name: "Left")]
        XCTAssert(s2 == nil, "Expected key to have no value")
        
        weakDictionary[Foot(name: "Left")] = nil
        XCTAssert(weakDictionary.count == 0, "Expected to be left holding no references \(weakDictionary.count)")
        
        f = Foot(name: "Right")
        s = Sock()
        weakDictionary[f!] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a reference \(weakDictionary.count)")

        s2 = weakDictionary[Foot(name: "Right")]
        XCTAssert(s2 != nil, "Expected key to have a accessible value")
        
        f = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a nil reference \(weakDictionary.count)")
        
        s2 = weakDictionary[Foot(name: "Right")]
        XCTAssert(s2 == nil, "Expected key to have no accessible value")
        
        weakDictionary[Foot(name: "Right")] = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a nil reference \(weakDictionary.count)")
        
        weakDictionary[Foot(name: "Fleeting")] = Sock()
        weakDictionary[Foot(name: "Fleeting1")] = Sock()
        XCTAssert(weakDictionary.count == 3, "Expected to be left holding nil references \(weakDictionary.count)")
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
        
        reaped[Foot(name: "Fleeting")] = Sock()
        reaped[Foot(name: "Fleeting1")] = Sock()
        reaped[Foot(name: "Fleeting2")] = Sock()
        reaped[Foot(name: "Fleeting3")] = Sock()
        reaped[Foot(name: "Fleeting4")] = Sock()
        reaped = reaped.reapedDictionary()
        XCTAssert(reaped.count == 0, "Expected to be left holding nil references \(weakDictionary.count)")
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
    
    func testMutatingReap() {
        var f: Foot? = Foot(name: "Left")
        let s: Sock = Sock()
        weakDictionary[f!] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding a single reference \(weakDictionary.count)")
        
        f = nil
        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 0, "Expected to be left holding no references \(weakDictionary.count)")
        
        weakDictionary[Foot(name: "Fleeting")] = Sock()
        weakDictionary[Foot(name: "Fleeting1")] = Sock()
        weakDictionary[Foot(name: "Fleeting2")] = Sock()
        weakDictionary[Foot(name: "Fleeting3")] = Sock()
        weakDictionary[Foot(name: "Fleeting4")] = Sock()
        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 0, "Expected to be left holding nil references \(weakDictionary.count)")
    }
    
    func testStrongification() {
        let f: Foot = Foot(name: "Left")
        var s: Sock? = Sock()
        weakDictionary[f] = s
        XCTAssert(weakDictionary.count == 1, "Expected to be left holding an empty reference \(weakDictionary.count)")
        
        var reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")
        
        var strongDictionary: [Foot: Sock]? = weakDictionary.toStrongDictionary()
        XCTAssert(strongDictionary?.count == 1, "Expected to be holding a single key value pair")
        
        s = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 1, "Expected to be left holding a single reference \(reaped.count)")
        
        weak var weakSock: Sock? = strongDictionary?[f]
        XCTAssert(weakSock != nil, "Expected to find sock in strong dictionary")
        
        strongDictionary = nil
        reaped = weakDictionary.reapedDictionary()
        XCTAssert(reaped.count == 0, "Expected unreferenced values to be released \(reaped.count)")
        
        s = Sock()
        weakDictionary[f] = s
        s = nil
        XCTAssert(weakDictionary.count == 1, "Expected to be holding an empty value reference")
        XCTAssert(weakDictionary.toStrongDictionary().count == 0, "Expected empty references to be ignored")
    }
 
    func testInitWithDictionary() {
        let f = Foot(name: "Left")
        var strongDict: [Foot:Sock]? = [
            f : Sock(),
            Foot(name: "Right") : Sock()
        ]
        
        weakDictionary = WeakKeyDictionary<Foot, Sock>(dictionary: strongDict!)
        XCTAssert(weakDictionary.count == 2, "Expected dictionary to be initialised with two references")
        
        let s = weakDictionary[f]
        XCTAssert(s != nil,"Expected value to be available for key")
        
        strongDict = nil
        weakDictionary.reap()
        XCTAssert(weakDictionary.count == 1, "Expected nullified weak references to be reaped")
    }
    
    func testReadmeExample() {
        var dictionary = WeakKeyDictionary<Foot, Sock>()
        var f: Foot? = Foot(name: "Left")
        let s: Sock? = Sock()
        dictionary[f!] = s
        print("\(f != nil ? "foot" : "nil") has \(dictionary[f!] != nil ? "a sock" : "no sock")")
        //prints: foot has a sock
        
        f = nil
        let e = Foot(name: "Left")
        print("\(f != nil ? "foot" : "nil") has \(dictionary[e] != nil ? "a sock" : "no sock")")        
        //prints: nil has no sock
        
        print("number of item in dictionary \(dictionary.count)")
        //prints: number of item in dictionary 1
        //This is because nil key/value references are not automatically nullified when the key or value is deallocated
        
        print("number of item in reaped dictionary \(dictionary.reapedDictionary().count)")
        //prints: number of item in reaped dictionary 0
        //Reaping the dictionary removes any keys without values and values not referenced by any key
    }
}

class Foot : Hashable {
    let footName : String
    
    init(name: String) {
        footName = name
    }
    
    public static func ==(lhs: Foot, rhs: Foot) -> Bool {
        return lhs.footName == rhs.footName
    }
    
    public var hashValue: Int {
        return footName.hash
    }
}
