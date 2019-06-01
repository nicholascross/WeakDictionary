//
//  WeakDictionary.swift
//  WeakDictionary
//
//  Created by Nicholas Cross on 19/10/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import Foundation

fileprivate class KeyBox<T: Hashable>: NSObject {
    let key: T

    init(_ key: T) {
        self.key = key
        super.init()
    }

    @objc override var hash: Int {
        return key.hashValue
    }

    @objc override func isEqual(_ object: Any?) -> Bool {
        return key == (object as! KeyBox<T>).key
    }
}

public struct WeakDictionary<Key: Hashable, Value: AnyObject> {

    private var storage: NSMapTable<KeyBox<Key>, Value>

    public init() {
        self.init(storage: NSMapTable(keyOptions: .strongMemory, valueOptions: .weakMemory))
    }

    public init(dictionary: [Key: Value]) {
        let newStorage = NSMapTable<KeyBox<Key>, Value>(keyOptions: .strongMemory, valueOptions: .weakMemory, capacity: dictionary.capacity)
        dictionary.forEach({ key, value in newStorage.setObject(value, forKey: KeyBox<Key>(key)) })
        self.init(storage: newStorage)
    }

    private init(storage: NSMapTable<KeyBox<Key>, Value>) {
        self.storage = storage
    }

    public func weakDictionary() -> WeakDictionary<Key, Value> {
        return self[startIndex ..< endIndex]
    }

    public func dictionary() -> [Key: Value] {
        var newStorage = [Key: Value]()

        for key in storage.keyEnumerator() {
            if let value = storage.object(forKey: (key as! KeyBox<Key>)) {
                newStorage[(key as! KeyBox<Key>).key] = value
            }
        }

        return newStorage
    }
}

public class WeakDictionaryIndex<Key: Hashable, Value> {
    fileprivate let key: KeyBox<Key>?

    private let position: UInt
    private var enumerator: NSEnumerator?

    fileprivate lazy var next: WeakDictionaryIndex<Key, Value> = {
        defer { self.enumerator = nil }
        return .init(enumerator: enumerator, position: position + 1)
    }()

    fileprivate convenience init(enumerator: NSEnumerator?, position: UInt = 0) {
        if let key = enumerator?.nextObject() as! KeyBox<Key>? {
            self.init(key: key, enumerator: enumerator, position: position)
        } else {
            self.init(key: nil, enumerator: nil, position: .max)
        }
    }

    fileprivate convenience init() {
        self.init(key: nil, enumerator: nil, position: .max)
    }

    private init(key: KeyBox<Key>?, enumerator: NSEnumerator?, position: UInt) {
        self.key = key
        self.enumerator = enumerator
        self.position = position
    }
}

extension WeakDictionaryIndex: Equatable {
    public static func == (lhs: WeakDictionaryIndex<Key, Value>, rhs: WeakDictionaryIndex<Key, Value>) -> Bool {
        return lhs.position == rhs.position
    }
}

extension WeakDictionaryIndex: Comparable {
    public static func < (lhs: WeakDictionaryIndex<Key, Value>, rhs: WeakDictionaryIndex<Key, Value>) -> Bool {
        return lhs.position < rhs.position
    }
}

extension WeakDictionary: Collection {

    public typealias Index = WeakDictionaryIndex<Key, Value>

    public var startIndex: Index {
        return Index(enumerator: storage.keyEnumerator())
    }

    public var endIndex: Index {
        return Index()
    }

    public func index(after index: Index) -> Index {
        return index.next
    }

    public subscript(position: Index) -> (Key, Value) {
        guard let key = position.key else {
            fatalError("Attempting to access WeakDictionary elements using an invalid index")
        }

        return (key.key, storage.object(forKey: key)!)
    }

    public subscript(key: Key) -> Value? {
        get {
            return storage.object(forKey: KeyBox<Key>(key))
        }

        set {
            guard let value = newValue else {
                storage.removeObject(forKey: KeyBox<Key>(key))
                return
            }

            storage.setObject(value, forKey: KeyBox<Key>(key))
        }
    }

    public subscript(bounds: Range<Index>) -> WeakDictionary<Key, Value> {
        let newStorage = NSMapTable<KeyBox<Key>, Value>(keyOptions: .strongMemory, valueOptions: .weakMemory)

        var pos = bounds.lowerBound
        while pos.key != nil && pos != bounds.upperBound {
            newStorage.setObject(storage.object(forKey: pos.key), forKey: pos.key)
            pos = pos.next
        }

        return WeakDictionary<Key, Value>(storage: newStorage)
    }
}

extension Dictionary where Value: AnyObject {
    public func weakDictionary() -> WeakDictionary<Key, Value> {
        return WeakDictionary<Key, Value>(dictionary: self)
    }
}
