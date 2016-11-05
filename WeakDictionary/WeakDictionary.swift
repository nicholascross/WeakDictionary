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
    
    public init(dictionary: [Key : Value]) {
        var newStorage = Dictionary<Key, WeakDictionaryReference<Value>>()
        dictionary.forEach({ key, value in newStorage[key] = WeakDictionaryReference<Value>(value: value) })
        storage = newStorage
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
            guard let valueRef = storage[key] else {
                return nil
            }
            
            return valueRef.value
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
    
    public func toStrongDictionary() -> [Key:Value] {
        var newStorage = Dictionary<Key, Value>()
        
        storage.forEach({
            key, value in
            if let v = value.value {
                newStorage[key] = v
            }
        })
        
        return newStorage
    }
}

public struct WeakKeyDictionary<Key : AnyObject & Hashable, Value : AnyObject> : Collection {
    public typealias Index = DictionaryIndex<WeakDictionaryKey<Key, Value>, WeakDictionaryReference<Value>>
    
    private var storage: WeakDictionary<WeakDictionaryKey<Key, Value>, Value>
    private let isValueRetainedByKey: Bool
    
    public init(withValuesRetainedByKey retainValues: Bool = false) {
        storage = WeakDictionary<WeakDictionaryKey<Key, Value>, Value>()
        isValueRetainedByKey = retainValues
    }
    
    public init(dictionary: [Key : Value], withValuesRetainedByKey retainValues: Bool = false) {
        var newStorage = WeakDictionary<WeakDictionaryKey<Key, Value>, Value>()
        
        dictionary.forEach({
            key, value in
            
            var keyRef: WeakDictionaryKey<Key, Value>!
            
            if !retainValues {
                keyRef = WeakDictionaryKey<Key, Value>(key: key)
            }
            else {
                keyRef = WeakDictionaryKey<Key, Value>(key: key, value: value)
            }
            
            
            newStorage[keyRef] = value
        })
        
        storage = newStorage
        isValueRetainedByKey = retainValues
    }
    
    private init(withStorage s: WeakDictionary<WeakDictionaryKey<Key, Value>, Value>, withValuesRetainedByKey retainValues: Bool = false) {
        storage = s
        isValueRetainedByKey = retainValues
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
    
    public subscript(position: Index) -> (WeakDictionaryKey<Key, Value>, WeakDictionaryReference<Value>) {
        get {
            return storage[position]
        }
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return storage[WeakDictionaryKey<Key, Value>(key: key)]
        }
        
        set {
            let retainedValue = isValueRetainedByKey ? newValue : nil
            let weakKey = WeakDictionaryKey<Key, Value>(key: key, value: retainedValue)
            storage[weakKey] = newValue
        }
    }
    
    public subscript(bounds: Range<Index>) -> WeakKeyDictionary<Key, Value> {
        let subStorage = storage[bounds.lowerBound ..< bounds.upperBound]
        var newStorage = WeakDictionary<WeakDictionaryKey<Key, Value>, Value>()
        
        subStorage.filter({ key, value in return key.key != nil && value.value != nil }).forEach({
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
    
    public func toStrongDictionary() -> [Key:Value] {
        var newStorage = Dictionary<Key, Value>()
        
        storage.forEach({
            key, value in
            if let k = key.key, let v = value.value {
                newStorage[k] = v
            }
        })
        
        return newStorage
    }
}

public struct WeakDictionaryReference<Value : AnyObject> {
    private weak var referencedValue: Value?
    
    fileprivate init(value: Value) {
        referencedValue = value
    }
    
    public var value: Value? {
        get {
            return referencedValue
        }
    }
}

private let nilKeyHash = UUID().hashValue

public struct WeakDictionaryKey<Key : AnyObject & Hashable, Value : AnyObject> : Hashable {
    
    private weak var baseKey: Key?
    private let hash: Int
    private var retainedValue: Value?
    
    public init(key: Key, value: Value? = nil) {
        baseKey = key
        retainedValue = value
        hash = key.hashValue
    }
    
    public static func ==(lhs: WeakDictionaryKey, rhs: WeakDictionaryKey) -> Bool {
        return lhs.baseKey == rhs.baseKey
    }
    
    public var hashValue: Int {
        return baseKey != nil ? hash : nilKeyHash
    }
    
    public var key: Key? {
        get {
            return baseKey
        }
    }
}
