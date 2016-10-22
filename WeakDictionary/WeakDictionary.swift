//
//  WeakDictionary.swift
//  WeakDictionary
//
//  Created by Nicholas Cross on 19/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import Foundation

public struct WeakDictionary<Key : Hashable, Value : AnyObject> : Collection {
    
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
    
    public subscript(position: Index) -> (Key, WeakDictionaryReference<Value>) {
        get {
            return (storage.keys[position], storage.values[position])
        }
    }
    
    public subscript(key: Key) -> Value? {
        get {
            guard let index = storage.keys.index(of: key) else {
                return nil
            }

            return self[index].1.value
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
    
    public mutating func reap() {
        storage = reapedDictionary().storage
    }
}

public struct WeakKeyDictionary<Key : AnyObject & Hashable, Value : AnyObject> : Collection {
    public typealias Index = DictionaryIndex<WeakDictionaryKey<Key>, WeakDictionaryReference<Value>>
    
    private var storage: WeakDictionary<WeakDictionaryKey<Key>, Value>
    
    public init() {
        storage = WeakDictionary<WeakDictionaryKey<Key>, Value>()
    }
    
    private init(withStorage s: WeakDictionary<WeakDictionaryKey<Key>, Value>) {
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
    
    public subscript(position: Index) -> (WeakDictionaryKey<Key>, WeakDictionaryReference<Value>) {
        get {
            return storage[position]
        }
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return storage[WeakDictionaryKey<Key>(key: key)]
        }
        
        set {
            storage[WeakDictionaryKey<Key>(key: key)] = newValue
        }
    }
    
    public subscript(bounds: Range<Index>) -> WeakKeyDictionary<Key, Value> {
        let subStorage = storage[bounds.lowerBound ..< bounds.upperBound]
        var newStorage = WeakDictionary<WeakDictionaryKey<Key>, Value>()
        
        subStorage.filter({ key, value in return key.baseKey != nil && value.value != nil }).forEach({
            key, value in
            newStorage[key] = value.value
        })
        
        return WeakKeyDictionary<Key, Value>(withStorage: newStorage)
    }
    
    public func reapedDictionary() -> WeakKeyDictionary<Key, Value> {
        return self[startIndex ..< endIndex]
    }
    
    public mutating func reap() {
        storage = reapedDictionary().storage
    }
}

public struct WeakDictionaryReference<Value : AnyObject> {
    fileprivate weak var value: Value?
}

private let nilKeyHash = UUID().hashValue

public struct WeakDictionaryKey<Key : AnyObject & Hashable> : Hashable {
    
    fileprivate weak var baseKey: Key?
    private let hash: Int
    
    
    public init(key: Key) {
        baseKey = key
        hash = key.hashValue
    }
    
    public static func ==(lhs: WeakDictionaryKey, rhs: WeakDictionaryKey) -> Bool {
        return lhs.baseKey == rhs.baseKey
    }
    
    public var hashValue: Int {
        return baseKey != nil ? hash : nilKeyHash
    }
}
