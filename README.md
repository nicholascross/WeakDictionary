# WeakDictionary
![build status](https://travis-ci.org/nicholascross/WeakDictionary.svg?branch=master)
![code coverage](https://img.shields.io/codecov/c/github/nicholascross/WeakDictionary.svg)
[![carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/WeakDictionary.svg)](https://cocoapods.org/pods/WeakDictionary) 
[![GitHub release](https://img.shields.io/github/release/nicholascross/WeakDictionary.svg)](https://github.com/nicholascross/WeakDictionary/releases) 
![Swift 3.0.x](https://img.shields.io/badge/Swift-3.0.x-orange.svg) 
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)

Naive (strong key/weak value) dictionary &amp; (weak key/weak value) dictionary implementations in swift

## WeakDictionary
* Values stored in the `WeakDictionary` are not retained
* Keys must implement the `Hashable` protocol
* `reapedDictionary` will create a new `WeakDictionary` with any orphaned value references removed
* `reap` will remove any orphaned value references for mutable dictionaries
* `toStrongDictionary` will create a new swift dictionary excluding any nullified value references
```swift
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
```

## WeakKeyDictionary
* Keys & values stored in the `WeakKeyDictionary` are not retained
* Keys must implement the `Hashable` protocol
* `reapedDictionary` will create a new `WeakKeyDictionary` with any orphaned key or value references removed
* `reap` will remove any orphaned key or value references for mutable dictionaries
* Optionally values may be retained by the key using `WeakKeyDictionary(withValuesRetainedByKey: true)`, the values will be released only after key references are reaped
* `toStrongDictionary` will create a new swift dictionary excluding any nullified key or value references
```swift
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
```
