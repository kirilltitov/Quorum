import Foundation

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
        // todo
        return nil
    }
}
