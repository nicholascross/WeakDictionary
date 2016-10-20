//
//  WeakDictionary.swift
//  WeakDictionary
//
//  Created by Nicholas Cross on 19/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import Foundation

public struct WeakDictionary<Key : Hashable & Comparable, Value : AnyObject> : Collection {
    
    public typealias Index = DictionaryIndex<Key, WeakDictionaryReference<Key, Value>>
    
    private var storage: Dictionary<Key, WeakDictionaryReference<Key, Value>>
    
    public init() {
        storage = Dictionary<Key, WeakDictionaryReference<Key, Value>>()
    }
    
    private init(withStorage s: Dictionary<Key, WeakDictionaryReference<Key, Value>>) {
        storage = s
    }
    
    public var startIndex : Index {
        return storage.startIndex
    }
    
    public var endIndex : Index {
        return storage.endIndex
    }
    
    public func index(after i: Index) -> Index {
        return storage.index(after: i)
    }
    
    public subscript(position: Index) -> WeakDictionaryReference<Key, Value> {
        get {
            let v = storage.values[position]
            return v
        }
    }
    
    public subscript(key: Key) -> Value? {
        get {
            guard let index = storage.keys.index(of: key) else {
                return nil
            }

            return self[index].value
        }
        
        set {
            guard let value = newValue else {
                storage[key] = nil
                return
            }
            
            storage[key] = WeakDictionaryReference<Key, Value>(key: key, value: value)
        }
    }
    
    public subscript(bounds: Range<Index>) -> [(Key, Value?)] {
        let subStorage = storage[bounds.lowerBound ..< bounds.upperBound]
        return subStorage.map({ key, value in
            return (key, value.value)
        })
    }
    
}

public struct WeakDictionaryReference<Key : Hashable & Comparable, Value : AnyObject> : Comparable {
    fileprivate let key: Key
    fileprivate weak var value: Value?
    
    public static func ==(lhs: WeakDictionaryReference, rhs: WeakDictionaryReference) -> Bool {
        return lhs.key == rhs.key
    }
    
    public static func <(lhs: WeakDictionaryReference, rhs: WeakDictionaryReference) -> Bool {
        return lhs.key < rhs.key
    }
    
    public static func <=(lhs: WeakDictionaryReference, rhs: WeakDictionaryReference) -> Bool {
        return lhs.key <= rhs.key
    }
    
    public static func >=(lhs: WeakDictionaryReference, rhs: WeakDictionaryReference) -> Bool {
        return lhs.key >= rhs.key
    }
    
    public static func >(lhs: WeakDictionaryReference, rhs: WeakDictionaryReference) -> Bool {
        return lhs.key > rhs.key
    }
}

