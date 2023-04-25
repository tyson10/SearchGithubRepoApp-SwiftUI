# SearchRepoApp

<aside>
💡 SwiftUI와 Combine을 학습하고 연습하기 위한 예제 앱

</aside>

## 앱 간단 설명

- [Github REST API](https://docs.github.com/ko/rest?apiVersion=2022-11-28)를 사용한 Repository 검색 앱.
- 최근 검색어, Search option등 제공하도록 함.

## 사용 기술

- SwiftUI
- Combine
- [Tuist](https://tuist.io)
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)

## 💥 Trouble Shooting
### Main thread checker에 의한 경고 발생
`The "Store" class is not thread-safe, and so all interactions with an instance of "Store" (including all of its scopes and derived view stores) must be done on the main thread.`
