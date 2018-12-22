public class Chain<Key: Hashable, Value> {
    public typealias Params = [String: Any]
    public typealias ProviderGetter = (Key, Params) -> Value?
    public typealias ProviderSetter = (Key, Value, Params) -> ()
    
    private class Provider {
        private let getter: ProviderGetter
        private let setter: ProviderSetter?
        private let params: Params
        
        public init(
            _ getter: @escaping ProviderGetter,
            _ setter: Optional<ProviderSetter>,
            _ params: Params
        ) {
            self.getter = getter
            self.setter = setter
            self.params = params
        }
        
        public func get(key: Key) -> Value? {
            return self.getter(key, self.params)
        }
        
        public func set(key: Key, value: Value) {
            self.setter?(key, value, self.params)
        }
    }
    
    private var providers: [Provider] = []
    
    @discardableResult public func add(
        getter: @escaping ProviderGetter,
        setter: Optional<ProviderSetter> = nil,
        params: Params = [:]
    ) -> Self {
        self.providers.append(Provider(getter, setter, params))
        return self
    }
    
    @discardableResult public func add(
        _ getter: @escaping ProviderGetter,
        params: Params = [:]
    ) -> Self {
        self.providers.append(Provider(getter, nil, params))
        return self
    }
    
    public func read(key: Key) -> Value? {
        guard self.providers.count > 0 else {
            print("Empty providers list")
            return nil
        }
        
        var result: Value? = nil
        var index: Int = 0
        
        for (idx, provider) in self.providers.enumerated() {
            index = idx
            if let value = provider.get(key: key) {
                result = value
                break
            }
        }
        
        if let result = result {
            self.providers.reversed()[(self.providers.count - index)...].forEach {
                $0.set(key: key, value: result)
            }
        }
        
        return result
    }
}
