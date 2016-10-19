//
//  WeakDictionary.swift
//  WeakDictionary
//
//  Created by Nicholas Cross on 19/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import Foundation

public struct WeakDictionary<Key : Hashable & Comparable, Value : AnyObject> : Collection {
    
    public typealias Index = DictionaryIndex<Key, WeakDictionaryIndex<Key, Value>>
    
    private var storage: Dictionary<Key, WeakDictionaryIndex<Key, Value>>
    
    public init() {
        storage = Dictionary<Key, WeakDictionaryIndex<Key, Value>>()
    }
    
    private init(withStorage s: Dictionary<Key, WeakDictionaryIndex<Key, Value>>) {
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
    
    public subscript(position: Index) -> WeakDictionaryIndex<Key, Value> {
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
            
            storage[key] = WeakDictionaryIndex<Key, Value>(key: key, value: value)
        }
    }
    
    public subscript(bounds: Range<Index>) -> [(Key, Value?)] {
        let subStorage = storage[bounds.lowerBound ..< bounds.upperBound]
        return subStorage.map({ key, value in
            return (key, value.value)
        })
    }
    
}

public struct WeakDictionaryIndex<Key : Hashable & Comparable, Value : AnyObject> : Comparable {
    fileprivate let key: Key
    fileprivate weak var value: Value?
    
    public static func ==(lhs: WeakDictionaryIndex, rhs: WeakDictionaryIndex) -> Bool {
        return lhs.key == rhs.key
    }
    
    public static func <(lhs: WeakDictionaryIndex, rhs: WeakDictionaryIndex) -> Bool {
        return lhs.key < rhs.key
    }
    
    public static func <=(lhs: WeakDictionaryIndex, rhs: WeakDictionaryIndex) -> Bool {
        return lhs.key <= rhs.key
    }
    
    public static func >=(lhs: WeakDictionaryIndex, rhs: WeakDictionaryIndex) -> Bool {
        return lhs.key >= rhs.key
    }
    
    public static func >(lhs: WeakDictionaryIndex, rhs: WeakDictionaryIndex) -> Bool {
        return lhs.key > rhs.key
    }
}

