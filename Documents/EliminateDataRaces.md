# Eliminate data races using Swift Concurrency

## Task Isolation

```swift
Task.detached {
    let fish = await hookFish()
    let meal = await cook(fish)
    await eat(meal)
}
```

- `detached`는 현재 context에서 벗어나 독립적인 context내에서 코드를 실행한다.

### Task의 특성

- Sequential
    - Task는 해야할 일이 있고, 처음부터 끝까지 순차적으로 수행함으로 보장한다.
- Asynchronous
    - 비동기로 수행되며 await 키워드를 통해 여러번 일시 중단 될 수 있다.
- Self-contained
    - 독립적이고 각 작업에는 자체적인 리소스가 있어서 독립적으로 작동할 수 있다.

### Task간 소통

```swift
enum Ripness {
    case hard
    case perfect
    case mushy(daysPast: Int)
}

struct Apple: Sendable {
    var weight: Double
    var ripness: Ripness
    
    mutating func ripen() async {
        // do something
    }
    mutating func slice() -> Int {
        // do something
    }
}
```

- `Apple`의 경우에 구조체이므로 객체가 값 타입으로서 기본적으로 Task간 이동이 있을때 복사를 하는 형식으로 넘어가기 때문에 Data race가 없다.

```swift
final class Duck {
    let name: String
    var currentHunger: HungerLevel
    
    func feed() -> Duck {...}
    func play() { }
    func produce() -> Egg {...}
}
```

- Class 프로퍼티의 경우 Task를 옮겨갈 때 복사가 아니라 특정 주소를 참조하기 때문에 Task마다 독립적이지 않고, Race condition이 발생한다.

### Sendable

> A type whose values can safely be passed across concurrency domains by copying.
> 
- 구조체는 값타입이므로 이미 `Sendable`을 준수하지만, 클래스는 참조 타입이므로 준수하지 않는다.

```swift
struct Task {
    static func detached(
        priority: TaskPriority? = nil,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task
}
```

- `Success`라는 결과값이 `Senable`을 준수해야 하므로, 클래스 타입을 반환하면 에러가 난다.

### 안전하게 공유하기

- 컴파일러는 다양한 지점에서 Sendable 검사를 한다.
- 원칙적으로 enum과 struct는 값을 복사해서 독립적인 값을 생성하기 때문에 내부의 값들도 모두 암시적으로 Sendable을 준수한다.
단, 내부에 클래스 인스턴스를 가지고 있다면 Sendable을 준수할 수 없다.

### Class에서 Sendable 준수하는 방법

1. `final`키워드 + 내부 프로퍼티를 모두 `let`(상수)으로 선언
    - immutable 함을 알림.
2. `@unchecked Sendable`을 붙임
    
    ```swift
    class ConcurrentCache: @unchecked Sendable {
        var lock: NSLock
        var storage: [Key: Value]
    }
    ```
    
    - lock(`NSLock`)을 이용해서 Sendable한 특성을 갖도록 구현하고, `@unchecked Sendable`를 붙여서 컴파일러가 검사하지 않도록 막는다.
    - 컴파일러가 검사하는 것을 막고 Sendable하도록 임의로 구현하는 것이므로 권장되지 않음.
    
    ### Sendable checking during task creation
    
    ```swift
    let rubberDuck = Duck(name:"Rubber Duck")
    Task.detached { @Sendable in
        rubberDuck.feed() // warning: Type 'Duck' does not conform to the 'Sendable' protocol
    }
    ```
    
    - Task 만들때 클로저 내부에 Sendable하지 않은 값을 캡쳐하면 에러가 뜬다.
        - Sendable 함수 or 클로저는 내부에 Sendable을 준수하는 값만 캡쳐해야 한다.
        - Sendable 클로저를 기대하는 맥락에서 위 조건을 만족 시키는 클로저라면 @Sendable을 명시하지 않더라도 암시적으로 Sendable을 준수한다.
        - 아래와 같이 함수 or 클로저에 Sendable을 명시할 수도 있다.
        
        ```swift
        // closure
        let sendableClosure = { @Sendable (number: Int) -> String in
            if number > 12 {
                return "More than a dozen."
            } else {
                return "Less than a dozen"
            }
        }
        
        // function
        @Sendable func sendableFunction(number: Int) -> String {
            if number > 12 {
                return "More than a dozen."
            } else {
                return "Less than a dozen"
            }
        }
        ```
        

## Actor isolation

- Actor를 사용해서 서로 다른 작업에서 접근할 수 있는 상태를 격리시켜 data race를 제거한다.

```swift
actor Island {
    var flock: [Duck]
    var food: [Apple]
    
    func advanceTime() {
        let totalslices = food.indices.reduce(0) { total, nextIndex in
            total + food[nextIndex].slice()
        }
        
        Task {
            flock.map (Duck.produce)
        }
        
        Task.detached {
            let ripeApples = await self.food.filter { $0.ripness == .perfect }
            print( "There are \(ripeApples.count) ripe apples on the island" )
        }
    }
}
```

- actor는 Sendable을 암시적으로 준수함.
- actor는 참조 타입이긴 하지만 내부의 모든것을 격리시켜서 독립성을 유지한다.
- detached 함수로 새로운 컨텍스트를 만들었고, 해당 컨텍스트에서는 actor의 독립성을 종속하지 않으므로 await를 사용해서 프로퍼티를 참조해야 한다.
이것은 actor 외부에서 접근하는 것으로 취급된다는 의미이다.

### Non-isolated code

```swift
extension Island {
    nonisolated func meetTheFlock() async {
        let flockNames = await flock.map { $0 .name } // warning: Non-sendable type '[Duck]' in implicitly asynchronous access to actor
isolated property 'flock' cannot cross actor boundary
    }
}
```

- actor와 상반된 개념으로 독립되지 않은 실행환경을 나타낸다.
- `nonisolated` 키워드로 해당 함수를 Non-isolated 상태로 만들 수 있다.
- actor 내부의 mutable한 상태에 접근하지 않는다는 것을 컴파일러에게 나타내는데 사용한다.
    - mutable한 상태에 접근하면 warning이 뜬다.
- synchronous한 호출이 가능해진다.
- async한 Non-isolated코드는 항상 글로벌 cooperative pool에서 실행되고 synchronous한 Non-isolated코드는 즉시 실행된다.

### @MainActor

- 메인 스레드에서 동작하도록 강제된 actor이다.
- UI 작업을 수행하는 클래스나 function에 붙여주면 된다.

```swift
@MainActor 
class ListViewModel: ObservableObject {
    @Published private(set) var result: Result<[Item], Error>?
    private let loader: ItemLoader
    ...

    func load() {
        Task {
            do {
                let items = try await loader.loadItems()
                result = .success(items)
            } catch {
                result = .failure(error)
            }
        }
    }
}
```

- 다만, Completion Handler나 Combine같이 Swift Concurrency가 아닌 다른 동시성 패턴을 사용하면 @MainActor는 아무 의미가 없어진다.
오직 async/await를 사용해야 한다.

## Atomicity(원자성)

```swift
func deposit(apples: [Apple], onto island: Island) async {
    var food = await island.food
    food += apples
    await island.food = food
}
// ❗️ Actor-isolated property 'food' can not be mutated from a non-isolated context
```

- actor 외부(Non-isolated context)에서 actor에 직접 접근해서 값을 바꾸면 안된다.
    - 잠재적 race condition이 생기기 떄문.

```swift
extension Island {
    func deposit(apples: [Apple]) async {
        var food = self.food
        food += apples
        self.food = food
    }
}
```

- actor내부(isolated context)에서 값을 안전하게 수정할 수 있다.

## Ordering

- 동시성 프로그램에서 작업의 수행 순서를 보장할 수 있도록 하는 개념.
- actor는 이벤트 순서에 따른 수행이 아니라 우선 순위에 따라서 수행하는 방법이다.(Task끼리의 우선순위에 따라 실행됨.)

### Ordering을 위한 도구

- Task
    - Task 블록 내에서는 순차적처리가 이루어 진다.
- AsyncStream
    - for-await-in 루프를 사용하면 순서를 보장받는다.
    
    ```swift
    for await event in eventStream {
        await process(event)
    }
    ```
    

---

## Xcode 설정

- Sendable로 Data race를 제거하는 방법을 사용할 때, 잠재적인 레이스 컨디션을 감지하도록 컴파일러 설정이 가능하다.
    - Project or Target → Build Settings → Swift Compiler – Language → Strict Conccurnecy Checking
    - 잠재적인 레이스 컨디션이 발견되면 warning을 띄움.

### Strict Conccurnecy Checking의 세팅값

1. Minimal
    - `Sendable`을 명시한 경우에만 검사함.
2. Targeted
    - `Sendable`을 명시하지 않아도 검사함.
    - `@preconcurrency`를 사용해서외부 모듈은 검사하지 않도록 할 수 있다.
    
    ```swift
    @preconcurrency import CommonUI
    ```
    
3. Complete
    - 모듈의 모든 코드에 대해 확인함. 가장 엄격한 방식.
    - data race를 완전히 제거함.

<aside>
💡 Data race에 대한 검사를 점점 엄격하게 진행하는 방식으로 진행해야 한다!

</aside>

## Tuist를 활용한 설정

```swift
// default setting 생성
let defaultSettings = Settings.settings(base: ["SWIFT_STRICT_CONCURRENCY": .string("complete")])

// target 생성시 default setting 파라미터로 전달
target = Target(
    name: name,
    platform: platform,
    product: .app,
    bundleId: "io.tuist.\(name)",
    infoPlist: .extendingDefault(with: infoPlist),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    dependencies: dependencies,
    settings: defaultSettings
)
```

- Build setting 관련 공식 문서
    
    [Build settings reference | Apple Developer Documentation](https://developer.apple.com/documentation/xcode/build-settings-reference)
