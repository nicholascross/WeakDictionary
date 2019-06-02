//
//  WeakKeyDictionary.swift
//  WeakDictionary-iOS
//
//  Created by Nicholas Cross on 2/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
import ObjectiveC

fileprivate var AssociatedObjectHandle: UInt8 = 0

fileprivate class WeakKeyBox<T: AnyObject & Hashable>: NSObject {
    weak var key: T!

    init(_ key: T) {
        self.key = key
        super.init()
        objc_setAssociatedObject(key, &AssociatedObjectHandle, self, .OBJC_ASSOCIATION_RETAIN)
    }

    @objc override var hash: Int {
        return key.hashValue
    }

    @objc override func isEqual(_ object: Any?) -> Bool {
        return key == (object as! WeakKeyBox<T>).key
    }
}

public struct WeakKeyDictionary<Key: AnyObject & Hashable, Value: AnyObject> {

    private var storage: NSMapTable<WeakKeyBox<Key>, Value>
    private let valuesRetainedByKey: Bool

    public init(valuesRetainedByKey: Bool = false) {
        self.init(
            storage: NSMapTable(keyOptions: .weakMemory, valueOptions: valuesRetainedByKey ? .strongMemory : .weakMemory),
            valuesRetainedByKey: valuesRetainedByKey
        )
    }

    public init(dictionary: [Key: Value], valuesRetainedByKey: Bool = false) {
        let newStorage = NSMapTable<WeakKeyBox<Key>, Value>(keyOptions: .weakMemory, valueOptions: valuesRetainedByKey ? .strongMemory : .weakMemory, capacity: dictionary.capacity)

        dictionary.forEach { key, value in
            newStorage.setObject(value, forKey: WeakKeyBox<Key>(key))
        }

        self.init(storage: newStorage, valuesRetainedByKey: valuesRetainedByKey)
    }

    private init(storage: NSMapTable<WeakKeyBox<Key>, Value>, valuesRetainedByKey: Bool = false) {
        self.storage = storage
        self.valuesRetainedByKey = valuesRetainedByKey
    }

    public func weakDictionary() -> WeakDictionary<Key, Value> {
        return dictionary().weakDictionary()
    }

    public func weakKeyDictionary() -> WeakKeyDictionary<Key, Value> {
        return self[startIndex ..< endIndex]
    }

    public func dictionary() -> [Key: Value] {
        var newStorage = [Key: Value]()

        for key in storage.keyEnumerator() {
            if let value = storage.object(forKey: (key as! WeakKeyBox<Key>)) {
                newStorage[(key as! WeakKeyBox<Key>).key] = value
            }
        }

        return newStorage
    }
}

public class WaekKeyDictionaryIndex<Key: AnyObject & Hashable, Value> {
    fileprivate let key: WeakKeyBox<Key>?

    private let position: UInt
    private var enumerator: NSEnumerator?

    fileprivate lazy var next: WaekKeyDictionaryIndex<Key, Value> = {
        defer { self.enumerator = nil }
        return .init(enumerator: enumerator, position: position + 1)
    }()

    fileprivate convenience init(enumerator: NSEnumerator?, position: UInt = 0) {
        if let key = enumerator?.nextObject() as! WeakKeyBox<Key>? {
            self.init(key: key, enumerator: enumerator, position: position)
        } else {
            self.init(key: nil, enumerator: nil, position: .max)
        }
    }

    fileprivate convenience init() {
        self.init(key: nil, enumerator: nil, position: .max)
    }

    private init(key: WeakKeyBox<Key>?, enumerator: NSEnumerator?, position: UInt) {
        self.key = key
        self.enumerator = enumerator
        self.position = position
    }
}

extension WaekKeyDictionaryIndex: Equatable {
    public static func == (lhs: WaekKeyDictionaryIndex<Key, Value>, rhs: WaekKeyDictionaryIndex<Key, Value>) -> Bool {
        return lhs.position == rhs.position
    }
}

extension WaekKeyDictionaryIndex: Comparable {
    public static func < (lhs: WaekKeyDictionaryIndex<Key, Value>, rhs: WaekKeyDictionaryIndex<Key, Value>) -> Bool {
        return lhs.position < rhs.position
    }
}

extension WeakKeyDictionary: Collection {

    public typealias Index = WaekKeyDictionaryIndex<Key, Value>

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
            fatalError("Attempting to access WeakKeyDictionary elements using an invalid index")
        }

        return (key.key, storage.object(forKey: key)!)
    }

    public subscript(key: Key) -> Value? {
        get {
            return storage.object(forKey: WeakKeyBox<Key>(key))
        }

        set {
            guard let value = newValue else {
                storage.removeObject(forKey: WeakKeyBox<Key>(key))
                return
            }

            storage.setObject(value, forKey: WeakKeyBox<Key>(key))
        }
    }

    public subscript(bounds: Range<Index>) -> WeakKeyDictionary<Key, Value> {
        let newStorage = NSMapTable<WeakKeyBox<Key>, Value>(keyOptions: .strongMemory, valueOptions: .weakMemory)

        var pos = bounds.lowerBound
        while pos.key != nil && pos != bounds.upperBound {
            newStorage.setObject(storage.object(forKey: pos.key), forKey: pos.key)
            pos = pos.next
        }

        return WeakKeyDictionary<Key, Value>(storage: newStorage)
    }
}

extension WeakDictionary where Key: AnyObject {
    public func weakKeyDictionary(valuesRetainedByKey: Bool = false) -> WeakKeyDictionary<Key, Value> {
        return WeakKeyDictionary<Key, Value>(dictionary: dictionary(), valuesRetainedByKey: valuesRetainedByKey)
    }
}

extension Dictionary where Key: AnyObject, Value: AnyObject {
    public func weakKeyDictionary(valuesRetainedByKey: Bool = false) -> WeakKeyDictionary<Key, Value> {
        return WeakKeyDictionary<Key, Value>(dictionary: self, valuesRetainedByKey: valuesRetainedByKey)
    }
}
