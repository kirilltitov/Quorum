import Foundation
import LGNCore

public protocol SyncStorage {
    associatedtype Key: Hashable
    associatedtype Value

    func getOrSet(
        by key: Key,
        _ getter: @escaping () async throws -> Value?
    ) async rethrows -> Value?

    func has(key: Key) async -> Bool
    func get(by key: Key) async -> Value?
    func set(by key: Key, value: Value) async -> Void
    @discardableResult func remove(by key: Key) async -> Value?

    func has0(key: Key) -> Bool
    func get0(by key: Key) -> Value?
    func set0(by key: Key, value: Value)
    func remove0(by key: Key) -> Value?
}

public extension SyncStorage {
    func has0(key: Key) -> Bool {
        self.get0(by: key) != nil
    }

    func has(key: Key) async -> Bool {
        self.has0(key: key)
    }

    func get(by key: Key) async -> Value? {
        self.get0(by: key)
    }

    func set(by key: Key, value: Value) async {
        self.set0(by: key, value: value)
    }

    func getOrSet(
        by key: Key,
        _ getter: @escaping () async throws -> Value?
    ) async rethrows -> Value? {
        if let value = self.get0(by: key) {
            return value
        }

        guard let result = try await getter() else {
            return nil
        }

        self.set0(by: key, value: result)

        return result
    }

    @discardableResult
    func remove(by key: Key) async -> Value? {
        self.remove0(by: key)
    }
}

public final class SyncDict<Key: Hashable, Value>: SyncStorage {
    private var storage: [Key: Value] = [:]

    public func get0(by key: Key) -> Value? {
        self.storage[key]
    }

    public func set0(by key: Key, value: Value) {
        self.storage[key] = value
    }

    public func remove0(by key: Key) -> Value? {
        self.storage.removeValue(forKey: key)
    }
}

final public class CacheLRU<Key: Hashable, Value>: SyncStorage {
    final private class DoublyLinkedList<T> {
        final class Node {
            var value: T
            var previous: Node?
            var next: Node?

            init(_ value: T) {
                self.value = value
            }
        }

        private(set) var count: Int = 0

        private var head: Node?
        private var tail: Node?

        public func addHead(_ value: T) -> Node {
            let node = Node(value)
            defer {
                self.head = node
                self.count += 1
            }

            guard let head = self.head else {
                tail = node
                return node
            }

            head.previous = node

            node.previous = nil
            node.next = head

            return node
        }

        public func moveToHead(_ node: Node) {
            guard node !== self.head else {
                return
            }
            let previous = node.previous
            let next = node.next

            previous?.next = next
            next?.previous = previous

            node.next = head
            node.previous = nil

            if node === tail {
                tail = previous
            }

            self.head = node
        }

        public func removeLast() -> Node? {
            guard let tail = self.tail else {
                return nil
            }

            let previous = tail.previous
            previous?.next = nil
            self.tail = previous

            if self.count == 1 {
                self.head = nil
            }

            self.count -= 1

            return tail
        }

        public func remove(_ node: Node) {
            node.previous?.next = node.next
            node.next?.previous = node.previous

            self.count -= 1
        }
    }

    private struct Box {
        public let key: Key
        public let value: Value
    }

    private let capacity: Int
    private let list = DoublyLinkedList<Box>()
    private var nodesDict: [Key: DoublyLinkedList<Box>.Node] = [:]

    public init(capacity: Int) {
        self.capacity = max(0, capacity)
    }

    public func set0(by key: Key, value: Value) {
        let box = Box(key: key, value: value)

        if let node = nodesDict[key] {
            node.value = box
            list.moveToHead(node)
        } else {
            let node = list.addHead(box)
            nodesDict[key] = node
        }

        if list.count > capacity {
            let nodeRemoved = list.removeLast()
            if let key = nodeRemoved?.value.key {
                nodesDict[key] = nil
            }
        }
    }

    public func get0(by key: Key) -> Value? {
        guard let node = nodesDict[key] else {
            return nil
        }

        list.moveToHead(node)

        return node.value.value
    }

    public func remove0(by key: Key) -> Value? {
        guard let node = nodesDict[key] else {
            return nil
        }

        list.remove(node)
        nodesDict[key] = nil

        return node.value.value
    }
}
