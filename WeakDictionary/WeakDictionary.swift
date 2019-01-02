//
//  WeakDictionary.swift
//  WeakDictionary
//
//  Created by Nicholas Cross on 19/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import Foundation

public struct WeakDictionary<Key: Hashable, Value: AnyObject> : Collection {

    public typealias Index = DictionaryIndex<Key, WeakDictionaryReference<Value>>

    private var storage: Dictionary<Key, WeakDictionaryReference<Value>>

    public init() {
        self.init(storage: Dictionary<Key, WeakDictionaryReference<Value>>())
    }

    public init(dictionary: [Key: Value]) {
        var newStorage = Dictionary<Key, WeakDictionaryReference<Value>>()
        dictionary.forEach({ key, value in newStorage[key] = WeakDictionaryReference<Value>(value: value) })
        self.init(storage: newStorage)
    }

    private init(storage: Dictionary<Key, WeakDictionaryReference<Value>>) {
        self.storage = storage
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

    public subscript(position: Index) -> (Key, WeakDictionaryReference<Value>) {
        get {
            return storage[position]
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

        subStorage.filter({ _, value in return value.value != nil }).forEach({
            key, value in
            newStorage[key] = value
        })

        return WeakDictionary<Key, Value>(storage: newStorage)
    }

    public func reapedDictionary() -> WeakDictionary<Key, Value> {
        return self[startIndex ..< endIndex]
    }

    public mutating func reap() {
        storage = reapedDictionary().storage
    }

    public func toStrongDictionary() -> [Key: Value] {
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
