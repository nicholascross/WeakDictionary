//
//  WeakKeyDictionary.swift
//  WeakDictionary-iOS
//
//  Created by Nicholas Cross on 2/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public struct WeakKeyDictionary<Key: AnyObject & Hashable, Value: AnyObject> : Collection {
    public typealias Index = DictionaryIndex<WeakDictionaryKey<Key, Value>, WeakDictionaryReference<Value>>
    
    private var storage: WeakDictionary<WeakDictionaryKey<Key, Value>, Value>
    private let valuesRetainedByKey: Bool
    
    public init(valuesRetainedByKey: Bool = false) {
        self.init(storage: WeakDictionary<WeakDictionaryKey<Key, Value>, Value>(), valuesRetainedByKey: valuesRetainedByKey)
    }
    
    public init(dictionary: [Key: Value], valuesRetainedByKey: Bool = false) {
        var newStorage = WeakDictionary<WeakDictionaryKey<Key, Value>, Value>()
        
        dictionary.forEach({
            key, value in
            
            var keyRef: WeakDictionaryKey<Key, Value>!
            
            if !valuesRetainedByKey {
                keyRef = WeakDictionaryKey<Key, Value>(key: key)
            } else {
                keyRef = WeakDictionaryKey<Key, Value>(key: key, value: value)
            }
            
            newStorage[keyRef] = value
        })
        
        self.init(storage: newStorage, valuesRetainedByKey: valuesRetainedByKey)
    }
    
    private init(storage: WeakDictionary<WeakDictionaryKey<Key, Value>, Value>, valuesRetainedByKey: Bool = false) {
        self.storage = storage
        self.valuesRetainedByKey = valuesRetainedByKey
    }
    
    public var startIndex: Index {
        return storage.startIndex
    }
    
    public var endIndex: Index {
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
            let retainedValue = valuesRetainedByKey ? newValue : nil
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
        
        return WeakKeyDictionary<Key, Value>(storage: newStorage)
    }
    
    public func reapedDictionary() -> WeakKeyDictionary<Key, Value> {
        return self[startIndex ..< endIndex]
    }
    
    public mutating func reap() {
        storage = reapedDictionary().storage
    }
    
    public func toStrongDictionary() -> [Key: Value] {
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
