# Async/Await

<aside>
💡 `CompletionHandler`를 사용하여 비동기 처리를 하면, `@escaping` 클로저를 연속적으로 사용해야 하는 경우가 있다.
ex) 이미지를 Data로 다운로드한 뒤 해당 데이터로 UIImage를 생성하는 동작.
순차적인 처리를 위해 클로저가 여러개 중첩되는 경우, 가독성에 상당히 나빠진다.
이런 문제는 Async/Await를 사용해서 해결이 가능하다!

</aside>

## CompletionHandler

- Async/Await가 등장하기 전에 클로저를 주입받아서 비동기 처리를 수행하는 방식이다.

```swift
// github 저장소를 검색한 후 결과값을 print후 language에 따른 color 데이터를 다시 요청하는 동작을 수행한다.
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

### 한계

```swift
func fetchPhoto(url: URL, completionHandler: @escaping (UIImage?, Error?) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
                completionHandler(nil, error)
        }

        if let data = data, let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode = 200 {
            DispatchQueue.main.async {
                completionHandler(UIImage(data: data), nil) // UIImage가 nil일 수 있다.
            }
        } else {
            completionHandler(nil, DogsError.invalidServerResponse()
        }
    }
    task.resume()
}
```

1. 제어 흐름이 복잡하다.
    1. `resume()` 이 호출된 이후에 `{ data, response, error in …. }`클로저가 실행된다.
    제어의 흐름이 아래 → 위 방향이 되어 부자연스럽다.
    2. 서로 다른 실행 context에서 실행되는 경우 복잡해진다.
        - 가장 바깥 레이어는 호출자의 스레드 or 큐에서 실행됨.
        - URLSessionTask의 completionHanldler는 Session의 delegate queue에서 실행됨.
        - 최종적인 completionHandler는 main queue에서 실행됨.
2. 개발자가 CompletionHandler 호출을 하지 않아도 오류가 발생하지 않는다.
    1. CompletionHandler가 항상 호출되어야 하나 이것은 전적으로 개발자에게 달려있다.
    잠재적인 버그 가능성 상승.
3. 가독성이 떨어진다.

## Async/Await 으로 CompletionHandler를 대체

```swift
let repositories: Repositories = try await self.networkService.request(endPoint: .search(option: .init(name: "swift")))
let langColors: LanguageColors = try await self.networkService.request(endPoint: .langColor)

public func request<T: Decodable>(endPoint: EndPoint) async throws -> T {
    guard let request = endPoint.request else {
        throw NetworkError.emptyRequest
    }
    
    var resultData: Data
    
    if let data = cache.cachedResponse(for: request)?.data {
        resultData = data
    } else {
        resultData = try await data(for: request)
    }
    
    let decodedData = try JSONDecoder().decode(T.self, from: resultData)
    
    return decodedData
}

private func data(for request: URLRequest) async throws -> Data {
    let (data, response) = try await session.data(for: request)
    
    guard isValid(response: response) else {
        throw NetworkError.invalidRequest
    }
    
    let cachedData = CachedURLResponse(response: response, data: data)
    
    cache.storeCachedResponse(cachedData, for: request)
    
    return data
}
```

### 개선된 점

```swift
func fetchPhoto(url: URL) async throws -> UIImage {
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                throw DogsError.invalidServerResponse
        }

    guard let image = UIImage(data: data) else {
        throw DogsError.unsupportedImage
    }

    return image
}
```

1. 제어의 흐름이 위→아래의 방향으로 자연스럽다. 마치 동기 코드처럼!
2. 동일한 Concurrency context에서 실행되어 스레딩 문제도 해결됐다.
3. CompletionHandler의 경우 오류를 던지지 않아도 알 수 없는 문제가 존재했으나, async 함수에서 에러를 `throw`하게되어 처리가 간단하다.
4. CompletionHandler를 항상 호출해야하는 단점이 없으므로 잠재적 버그 발생의 가능성이 낮아졌다.

### Continuation

- 동기식 코드와 비동기식 코드간의 인터페이스를 위한 매커니즘
- async함수를 수동제어 함.

![Untitled](Images/async_await_1.png)

```swift
func persistentPosts() async throws -> [Post] {
    typealias PostContinuation = CheckedContinuation<[Post], Error>
    return try await withCheckedThrowingContinuation { (continuation: PostContinuation) in
        
        // 기존 CompletionHandler를 활용한 함수.
        self.getPersistentPosts { posts, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: posts)
            }
        }
    }
}
```

- `resume`은 한 번만 실행되어야 한다.

## Thread

### Sync

![sync context에서 스레드 제어권 흐름](Images/async_await_2.png)

sync context에서 스레드 제어권 흐름

- sync context에서는 함수가 호출되면 스레드 제어권을 가져오고, 실행이 끝나면 상위 함수에게 다시 제어권을 반환한다.
- Thread block이 일어난다.

### Async

![async context에서 스레드 제어권 흐름](Images/async_await_3.png)

async context에서 스레드 제어권 흐름

- Suspending
    - `await`시 스레드 제어권을 상위함수가 아닌 시스템에게 넘기는 방식으로 스레드 제어권을 포기하는 방식.
    - Suspending이 되고나면 시스템은 해당 스레드에 다른 작업을 실행할 수 있다.
    - Thread unblock
- Resume이 되면 suspend가 끝나고 다시 상위 함수로 돌아온다.
