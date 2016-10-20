//
//  WeakDictionary.swift
//  WeakDictionary
//
//  Created by Nicholas Cross on 19/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import Foundation

public struct WeakDictionary<Key : Hashable & Comparable, Value : AnyObject> : Collection {
    
    public typealias Index = DictionaryIndex<Key, WeakDictionaryReference<Value>>
    
    private var storage: Dictionary<Key, WeakDictionaryReference<Value>>
    
    public init() {
        storage = Dictionary<Key, WeakDictionaryReference<Value>>()
    }
    
    private init(withStorage s: Dictionary<Key, WeakDictionaryReference<Value>>) {
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
    
    public subscript(position: Index) -> WeakDictionaryReference<Value> {
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
            
            storage[key] = WeakDictionaryReference<Value>(value: value)
        }
    }
    
    public subscript(bounds: Range<Index>) -> WeakDictionary<Key, Value> {
        let subStorage = storage[bounds.lowerBound ..< bounds.upperBound]
        var newStorage = Dictionary<Key, WeakDictionaryReference<Value>>()
        
        subStorage.filter({ key, value in return value.value != nil }).forEach({
            key, value in
            newStorage[key] = value
        })
        
        return WeakDictionary<Key, Value>(withStorage: newStorage)
    }
    
    public func reapedDictionary() -> WeakDictionary<Key, Value> {
        return self[startIndex ..< endIndex]
    }
}

public struct WeakDictionaryReference<Value : AnyObject> {
    fileprivate weak var value: Value?
}

