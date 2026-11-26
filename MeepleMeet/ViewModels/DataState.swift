enum DataState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}
