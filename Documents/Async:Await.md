# Async/Await

<aside>
💡 `CompletionHandler`를 사용하여 비동기 처리를 하면, `@escaping` 클로저를 연속적으로 사용해야 하는 경우가 있다.
ex) 이미지를 Data로 다운로드한 뒤 해당 데이터로 UIImage를 생성하는 동작.
순차적인 처리를 위해 클로저가 여러개 중첩되는 경우, 가독성에 상당히 나빠진다.
이런 문제는 **Async/Await**를 사용해서 해결이 가능하다!

</aside>

## CompletionHandler

- Async/Await가 등장하기 전에 클로저를 주입받아서 비동기 처리를 수행하는 방식이다.

### 한계

- github 저장소를 검색한 후 결과값을 print후 language에 따른 color 데이터를 다시 요청하는 동작을 수행한다.
- escaping 클로저가 중첩되며 가독성이 낮은 코드가 작성된다.

```swift
self.search(with: .init(name: "swift")) { result in
    switch result {
    case .success(let repositories):
        print(repositories)
        self.getLangColor { result in
            switch result {
            case .success(let colors):
                print(colors)
            case .failure(let error):
                print(error)
            }
        }
    case .failure(let error):
        print(error)
    }
}

private func search(
    with option: SearchOption,
    completion: @escaping (Result<Repositories, NetworkError>) -> Void) {
        self.networkService.request(endPoint: .search(option: option), completion: completion)
}

private func getLangColor(
    completion: @escaping (Result<LanguageColors, NetworkError>) -> Void) {
        self.networkService.request(endPoint: .langColor, completion: completion)
}
```