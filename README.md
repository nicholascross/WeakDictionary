# WeakDictionary
![build status](https://travis-ci.org/nicholascross/WeakDictionary.svg?branch=master)
![code coverage](https://img.shields.io/codecov/c/github/nicholascross/WeakDictionary.svg)
[![carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/WeakDictionary.svg)](https://cocoapods.org/pods/WeakDictionary) 
[![GitHub release](https://img.shields.io/github/release/nicholascross/WeakDictionary.svg)](https://github.com/nicholascross/WeakDictionary/releases) 
![Swift 4.2.x](https://img.shields.io/badge/Swift-4.2.x-orange.svg) 
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)

A naive (strong key/weak value) dictionary &amp; (weak key/weak value) dictionary implementation in swift.

Apple provides an existing implementation and you should use it instead.  [NSMapTable](https://nshipster.com/nshashtable-and-nsmaptable/) also has the advantage that you dont need to manually trigger clean up of old nil references.

It is also worth considering if clean up of references is even needed for your scenario.  In cases where the dictionary itself is shortlived or the values are likely to be recreated for the same keys then it is probably sufficient to use a standard swift dictionary with a [weak box wrapper](https://gist.github.com/nicholascross/8285cef20b1f5f171557478647cc0cdd) instead.

**What are some differences from NSMapTable?**
 - Use of equality operator for key comparison
 - Supports suscripts and `Collection` protocol inherited behaviour
 - Keys can optionally retain values as long as the key itself is retained the associated value can be retained
 - Manual nil reference clean up required.  Weak references are reclaimed as normal but container objects are left holding nil references until reaping is triggered

## WeakDictionary

* Values stored in the `WeakDictionary` are not retained
* Keys must implement the `Hashable` protocol
* `weakDictionary` will create a new `WeakDictionary` with any orphaned value references removed
* `weakKeyDictionary` will create a new `WeakKeyDictionary` with any orphaned value references removed, this will only work if the key is a class type
* `dictionary` will create a new swift dictionary excluding any nullified value references
* `reap` will remove any orphaned value references for mutable dictionaries

```swift
    var dictionary = WeakDictionary<String, ExampleValue>()
    var value: ExampleValue? = ExampleValue()
    dictionary["key"] = value

    print("\(dictionary["key"] != nil ? "has value" : "value missing")")
    //prints: has value

    value = nil
    print("\(dictionary["key"] != nil ? "has value" : "value missing")")
    //prints: value missing

    private class ExampleValue { }
```

## WeakKeyDictionary

* Keys & values stored in the `WeakKeyDictionary` are not retained
* Keys must implement the `Hashable` protocol
* `weakDictionary` will create a new `WeakDictionary` with any orphaned value references removed
* `weakKeyDictionary` will create a new `WeakKeyDictionary` with any orphaned value references removed
* `dictionary` will create a new swift dictionary excluding any nullified key or value references
* `reap` will remove any orphaned key or value references for mutable dictionaries
* Optionally values may be retained by the key using `WeakKeyDictionary(valuesRetainedByKey: true)`, the values will be released only after key references are reaped

```swift
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

    private class ExampleValue { }

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
```
