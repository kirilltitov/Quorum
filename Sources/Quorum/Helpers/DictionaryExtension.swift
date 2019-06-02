import Foundation

public extension Dictionary where Key == String, Value == Any {
    fileprivate func _get<T>(path: [String]) -> T? {
        var root = self

        for idx in 0 ..< path.count - 1 {
            guard let _root = root[path[idx]] as? [String: Any] else {
                return nil
            }
            root = _root
        }

        guard let result = root[path[path.endIndex - 1]] as? T else {
            return nil
        }

        return result
    }

    subscript<T>(path: String...) -> T? {
        return self._get(path: path)
    }
}

public extension Data {
    private func _json<T>(path: [String]) -> T? {
        guard
            let rawJson = try? JSONSerialization.jsonObject(with: self),
            let json = rawJson as? [String: Any]
        else {
            return nil
        }

        return json._get(path: path)
    }

    subscript<T>(json path: String...) -> T? {
        return self._json(path: path)
    }

    subscript<T>(jsonPath path: String) -> T? {
        return self._json(path: path.split(separator: "/").map { String($0) })
    }
}
