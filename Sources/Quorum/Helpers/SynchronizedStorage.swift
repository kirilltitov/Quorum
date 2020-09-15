import Foundation
import LGNCore
import NIO

public protocol SyncStorage {
    associatedtype Key: Hashable
    associatedtype Value

    var eventLoops: [EventLoop] { get }

    func getOrSet(
        by key: Key,
        on eventLoop: EventLoop,
        _ getter: @escaping () -> EventLoopFuture<Value?>
    ) -> EventLoopFuture<Value?>

    func has(key: Key, on eventLoop: EventLoop) -> EventLoopFuture<Bool>
    func get(by key: Key, on eventLoop: EventLoop) -> EventLoopFuture<Value?>
    func set(by key: Key, value: Value, on eventLoop: EventLoop) -> EventLoopFuture<Void>
    @discardableResult func remove(by key: Key, on eventLoop: EventLoop) -> EventLoopFuture<Value?>

    func has0(key: Key) -> Bool
    func get0(by key: Key) -> Value?
    func set0(by key: Key, value: Value)
    func remove0(by key: Key) -> Value?
}

fileprivate func initEventLoops(from eventLoopGroup: EventLoopGroup, eventLoopCount: Int) -> [EventLoop] {
    return (0 ..< eventLoopCount).map { _ in eventLoopGroup.next() }
}

public extension SyncStorage {
    func getEventLoop(key: Key) -> EventLoop {
        return self.eventLoops[Int(key.hashValue.magnitude % UInt(self.eventLoops.count))]
    }

    func has0(key: Key) -> Bool {
        return self.get0(by: key) != nil
    }

    func has(key: Key, on eventLoop: EventLoop) -> EventLoopFuture<Bool> {
        return self
            .getEventLoop(key: key)
            .makeFuture()
            .map { self.has0(key: key) }
            .hop(to: eventLoop)
    }

    func get(by key: Key, on eventLoop: EventLoop) -> EventLoopFuture<Value?> {
        return self
            .getEventLoop(key: key)
            .makeFuture()
            .map { self.get0(by: key) }
            .hop(to: eventLoop)
    }

    func set(by key: Key, value: Value, on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        return self
            .getEventLoop(key: key)
            .makeFuture()
            .map { self.set0(by: key, value: value) }
            .hop(to: eventLoop)
    }

    func getOrSet(
        by key: Key,
        on eventLoop: EventLoop,
        _ getter: @escaping () -> EventLoopFuture<Value?>
    ) -> EventLoopFuture<Value?> {

        let keyEventLoop = self.getEventLoop(key: key)

        return keyEventLoop
            .makeSucceededFuture()
            .flatMap {
                if let value = self.get0(by: key) {
                    return keyEventLoop.makeSucceededFuture(value)
                }

                return getter().map { maybeResult in
                    if let result = maybeResult {
                        self.set0(by: key, value: result)
                    }
                    return maybeResult
                }
            }
            .hop(to: eventLoop)
    }

    @discardableResult func remove(by key: Key, on eventLoop: EventLoop) -> EventLoopFuture<Value?> {
        return self
            .getEventLoop(key: key)
            .makeFuture()
            .map { self.remove0(by: key) }
            .hop(to: eventLoop)
    }
}

public final class SyncDict<Key: Hashable, Value>: SyncStorage {
    public let eventLoops: [EventLoop] = []
    private var storage: [Key: Value] = [:]

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

    public let eventLoops: [EventLoop]

    public init(capacity: Int, eventLoopGroup: EventLoopGroup, eventLoopCount: Int) {
        self.eventLoops = initEventLoops(from: eventLoopGroup, eventLoopCount: eventLoopCount)
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
