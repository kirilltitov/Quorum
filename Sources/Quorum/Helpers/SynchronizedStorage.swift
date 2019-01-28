import Foundation
import LGNCore
import NIO

public protocol SyncStorage {
    associatedtype Key: Hashable
    associatedtype Value

    var queue: DispatchQueue { get }

    func getOrSet(
        by key: Key,
        on eventLoop: EventLoop,
        _ getter: @escaping () -> Future<Value?>
    ) -> Future<Value?>

    func has(key: Key, on eventLoop: EventLoop) -> Future<Bool>
    func get(by key: Key, on eventLoop: EventLoop) -> Future<Value?>
    func set(by key: Key, value: Value, on eventLoop: EventLoop) -> Future<Void>
    @discardableResult func remove(by key: Key, on eventLoop: EventLoop) -> Future<Value?>

    func has0(key: Key) -> Bool
    func get0(by key: Key) -> Value?
    func set0(by key: Key, value: Value)
    func remove0(by key: Key) -> Value?
}

extension SyncStorage {
    public static func getQueue() -> DispatchQueue {
        return DispatchQueue(
            label: "games.1711.SyncStorage.\(Self.self)",
            qos: .userInitiated,
            attributes: .concurrent
        )
    }

    public func has0(key: Key) -> Bool {
        return self.get0(by: key) != nil
    }

    public func has(key: Key, on eventLoop: EventLoop) -> Future<Bool> {
        let promise: Promise<Bool> = eventLoop.newPromise()

        self.queue.async {
            promise.succeed(result: self.has0(key: key))
        }

        return promise.futureResult
    }

    public func get(by key: Key, on eventLoop: EventLoop) -> Future<Value?> {
        let promise: Promise<Value?> = eventLoop.newPromise()

        self.queue.async {
            promise.succeed(result: self.get0(by: key))
        }

        return promise.futureResult
    }

    public func set(by key: Key, value: Value, on eventLoop: EventLoop) -> Future<Void> {
        let promise: Promise<Void> = eventLoop.newPromise()

        self.queue.async(flags: .barrier) {
            self.set0(by: key, value: value)
            promise.succeed(result: ())
        }

        return promise.futureResult
    }

    public func getOrSet(
        by key: Key,
        on eventLoop: EventLoop,
        _ getter: @escaping () -> EventLoopFuture<Value?>
    ) -> EventLoopFuture<Value?> {
        let promise: Promise<Value?> = eventLoop.newPromise()

        self.queue.async(flags: .barrier) {
            if let value = self.get0(by: key) {
                promise.succeed(result: value)
                return
            }

            do {
                let result = try getter().wait()
                if let result = result {
                    self.set0(by: key, value: result)
                }
                promise.succeed(result: result)
            } catch {
                promise.fail(error: error)
            }
        }

        return promise.futureResult
    }

    @discardableResult public func remove(by key: Key, on eventLoop: EventLoop) -> Future<Value?> {
        let promise: Promise<Value?> = eventLoop.newPromise()

        self.queue.async(flags: .barrier) {
            promise.succeed(result: self.remove0(by: key))
        }

        return promise.futureResult
    }
}

public final class SyncDict<Key: Hashable, Value>: SyncStorage {
    public let queue: DispatchQueue
    private var storage: [Key: Value] = [:]

    public init(queue: DispatchQueue = SyncDict.getQueue()) {
        self.queue = queue
    }

    public func get0(by key: Key) -> Value? {
        return self.storage[key]
    }

    public func set0(by key: Key, value: Value) {
        self.storage[key] = value
    }

    public func remove0(by key: Key) -> Value? {
        return self.storage.removeValue(forKey: key)
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

    public let queue: DispatchQueue

    public init(capacity: Int, queue: DispatchQueue = CacheLRU.getQueue()) {
        self.capacity = max(0, capacity)
        self.queue = queue
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

