[![Tuist badge](https://img.shields.io/badge/Powered%20by-Tuist-blue)](https://tuist.io)

# SearchRepoApp

<aside>
💡 SwiftUI와 Combine을 학습하고 연습하기 위한 예제 앱

</aside>

## 앱 간단 설명

- Github Repository 검색 앱.
- 최근 검색어, Search option등 제공하도록 함.

## 사용 기술

- SwiftUI
- Combine
- [Tuist](https://tuist.io)
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [Swift Concurrency(async/await)](Documents/Concurrency.md)

## 💥 Trouble Shooting
### Main thread checker에 의한 경고 발생
`The "Store" class is not thread-safe, and so all interactions with an instance of "Store" (including all of its scopes and derived view stores) must be done on the main thread.`
- `Store` 클래스가 thread-safe하지 않으므로 `Store`객체와 상호 작용을 위한 동작은 main thread에서 수행되어야 함.

```swift
var task: EffectTask<Action> = .none

/// Action을 반환할 때 receive(on:) 함수로 메인 스케줄러에서 동작하도록 구현
task = .init(
    search(with: option)
        .tryMap({ ($0, option) })
        .receive(on: DispatchQueue.main)
        .tryMap(Action.append(repos:option:))
        .catch { Just(.handleError($0)) }
)
```

## 참고 자료
- [Github REST API](https://docs.github.com/ko/rest?apiVersion=2022-11-28)
- [ComposableArchitecture Docs](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture)
