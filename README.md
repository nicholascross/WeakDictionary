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
private class Example {

}

var dictionary = WeakDictionary<String, Example>()
var value: Example? = Example()
dictionary["key"] = value

print("\(dictionary["key"] != nil ? "has value" : "value missing")")
//prints: has value

value = nil
print("\(dictionary["key"] != nil ? "has value" : "value missing")")
//prints: value missing
```

## WeakKeyDictionary
* Keys & values stored in the `WeakKeyDictionary` are not retained
* Keys must implement the `Hashable` protocol
* `reapedDictionary` will create a new `WeakKeyDictionary` with any orphaned key or value references removed
* `reap` will remove any orphaned key or value references for mutable dictionaries
* Optionally values may be retained by the key using `WeakKeyDictionary(withValuesRetainedByKey: true)`, the values will be released only after key references are reaped
* `toStrongDictionary` will create a new swift dictionary excluding any nullified key or value references
```swift
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

var dictionary = WeakKeyDictionary<Example1, Example>()
var f: Example1? = Example1(name: "value")
let s: Example? = Example()
dictionary[f!] = s
print("\(dictionary[f!] != nil ? "an example exits" : "no example exits")")
//prints: an example exits

f = nil
let e = Example1(name: "Left")
print("\(dictionary[e] != nil ? "an example exits" : "no example exits")")
//prints: no example exits

print("number of item in dictionary \(dictionary.count)")
//prints: number of item in dictionary 1
//This is because nil key/value references are not automatically nullified when the key or value is deallocated

print("number of item in reaped dictionary \(dictionary.reapedDictionary().count)")
//prints: number of item in reaped dictionary 0
//Reaping the dictionary removes any keys without values and values not referenced by any key
```
