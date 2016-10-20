# WeakDictionary
Naive (strong key/weak value) dictionary &amp; (weak key/weak value) dictionary implementations in swift

## WeakDictionary
* Values stored in the `WeakDictionary` are not retained
* `reapedDictionary` will create a new `WeakKeyDictionary` with any orphaned value references removed
```swift
let dictionary = WeakDictionary<String, Shoe>()
var shoe: Shoe? = Shoe()
dictionary["foot"] = shoe

print("foot has \(dictionary["foot"] != nil ? "a shoe" : "no shoe")")
//prints: foot has a shoe

s = nil
print("foot has \(dictionary["foot"] != nil ? "a shoe" : "no shoe!")")
//prints: foot has no shoe!
```

## WeakKeyDictionary
* Keys & values stored in the `WeakKeyDictionary` are not retained
* A value is **NOT** nullified when a key is deallocated, this means an equivalent key will still return the value
* Keys must implement the `Identifiable` protocol
* `reapedDictionary` will create a new `WeakKeyDictionary` with any orphaned key or value references removed
```swift
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

let dictionary = WeakKeyDictionary<Foot, Sock>()
var f: Foot? = Foot(name: "Left")
var s: Sock? = Sock()
dictionary[f!] = s
print("\(f != nil ? "foot" : "nil") has \(dictionary[f!] != nil ? "a sock" : "no sock")")        
//prints: foot has a sock

f = nil
let e = Foot(name: "Left")
print("\(f != nil ? "foot" : "nil") has \(dictionary[e] != nil ? "a sock" : "no sock")")        
//prints: nil has a sock

s = nil
print("\(f != nil ? "foot" : "nil") has \(dictionary[e] != nil ? "a sock" : "no sock")")        
//prints: nil has no sock
```

### Identifiable
```swift
public protocol Identifiable {
    associatedtype Identity: Hashable
    func identifier() -> Identity
}
```
