# Actor

## Data race

- 서로 다른 스레드가 동일한 데이터에 동시에 접근할 때, 1개의 스레드가 데이터를 수정하게 되면 스레드간의 경쟁이 발생하여 예측할 수 없는 결과를 낳는다.

```swift
class MyAppleBox {
    var apple = 3

    func eat() {
        apple -= 1
    }
}

var myAppleBox = MyAppleBox()

Task {
    myAppleBox.eat()
}

Task {
    print(myAppleBox.apple)
}
```

- 각 Task를 서로 다른 스레드에서 동작하게 한다면 실행의 순서를 보장할 수 없으므로, 출력되는 결과가 매 번 동일한지에 대한 보장을 할 수 없다.

### 문제

- 여러 스레드에서 데이터에 접근하는 것이 아니라, 스레드중 하나에서 데이터를 수정하면 문제가 된다!

### 해결책

<aside>
💡 여러 스레드에서 공유되지 않도록 하거나, 데이터가 수정되지 않게 하거나.

</aside>

- 값 타입 데이터를 let으로 선언
    - 데이터를 변경할 수 없으므로 Data race로 부터 안전함.
    - But, 데이터 변경 불가능.
- Atomics, Locks, Serial DispatchQueue 등과 같은 Swift의 기능을 이용함
    - 구현시에 정확히 지켜야 하는 순서나 규칙들이 있으므로 까다로운 편.
- Actor 사용

## Actor

- 프로퍼티, 메소드, 이니셜라이저, 서브스크립트 등을 가질 수 있다.
- 프로토콜 채택 및 익스텐션 구현이 가능하다.
- 참조 타입이다. 공유 가능한 가변 상태를 표현하기 위해서다.
- 인스턴스 데이터를 나머지와 분리하고, 해당 데이터에 대한 동기적인 접근을 보장한다.
    - Actor 내부의 상태와 외부를 격리하는 특성이 있어 Data race 방지.
    - Actor의 상태에 접근하는 방법은 Actor를 통한 방법이 유일하고, Swift 내부에서 여러 스레드가 동시에 Actor에 접근하지 않도록 막아줌.

### 예제

```swift
actor MyAppleBox {
    var apple = 3

    func eat() {
        apple -= 1
    }
}

var myAppleBox = MyAppleBox()

Task {
    await myAppleBox.eat()
}

Task {
    await print(myAppleBox.apple)
}
```

- `await`키워드는 해당 데이터에 먼저 접근한 스레드가 있다면 기다리겠다는 의미다.

## Actor reentrancy
- 아래의 코드는 은행 계좌를 Actor로 선언하고 돈을 인출하는 함수가 구현된 코드임.

```swift
// 선언부
actor BankAccount {
    
    private var balance = 1000
    
    func withdraw(_ amount: Int) async {
        
        print("🤓 Check balance for withdrawal: \(amount)")
        
        guard canWithdraw(amount) else {
            print("🚫 Not enough balance to withdraw: \(amount)")
            return
        }
        
        guard await authorizeTransaction() else {
            return
        }
        
        print("✅ Transaction authorized: \(amount)")
        
        balance -= amount
        
        print("💰 Account balance: \(balance)")
    }
    
    private func canWithdraw(_ amount: Int) -> Bool {
        return amount <= balance
    }
    
    private func authorizeTransaction() async -> Bool {
        
        // Wait for 1 second
        try? await Task.sleep(nanoseconds: 1 * 1000000000)
        
        return true
    }
}

// 실행
let account = BankAccount()

let withdraw_1 = Task {
    await account.withdraw(800)
}

let withdraw_2 = Task {
    await account.withdraw(500)
}

// 결과
// 🤓 Check balance for withdrawal: 800
// 🤓 Check balance for withdrawal: 500
// ✅ Transaction authorized: 800
// 💰 Account balance: 200
// ✅ Transaction authorized: 500
// 💰 Account balance: -300
```

### 문제의 동작 과정

1. 800 인출에 대한 잔액 체크
2. 500 인출에 대한 잔액 체크
3. 800 인출에 대한 잔액 업데이트
4. 500 인출에 대한 잔액 업데이트

위 과정은 1번 이후에 호출된 `await` `authorizeTransaction()` 때문에 해당 함수는 Suspend되고 `withdraw_2`의 동작을 수행하게 된다.
결과적으로, 800인출에 대한 결과를 500인출에 반영하지 못해 잔액보다 더 많은 금액이 인출이 가능해진다.

**전형적인 Data Reentrancy 문제이다.**

### ****Designing Actor for Reentrancy****

애플에 의하면 actor의 reentrancy는 데드락을 방지하지만, 각각의 `await`에서 가변적인 상태(변수)가 동일하게 유지될 것을 보장하지는 않는다.
그러므로, 각 await가 잠재적인 Suspend 지점이며 await 전후의 가변 상태(변수)값이 변해있을 수 있다는 것을 고려해야 한다.
**이것은 개발자의 몫이다.**

- 가장 간단한 방법은 아래와 같이 `await` 이후에 다시 한 번 잔액을 체크하는 것이다.

```swift
func withdraw(_ amount: Int) async {
    
    print("🤓 Check balance for withdrawal: \(amount)")
    
    guard canWithdraw(amount) else {
        print("🚫 Not enough balance to withdraw: \(amount)")
        return
    }
    
    guard await authorizeTransaction() else {
        return
    }
    
    // await 이후로 잔액이 변경되었을 수 있으므로 다시 한 번 체크!
    guard canWithdraw(amount) else {
        print("🚫 Not enough balance to withdraw: \(amount)")
        return
    }
    
    print("✅ Transaction authorized: \(amount)")
    
    balance -= amount
    
    print("💰 Account balance: \(balance)")
}
```
## Actor isolation

<aside>
💡 Actor가 Data race를 방지하는 방식이다.

</aside>

- stored, computed instance properties
- instance methods
- instance subscripts

actor에서 위와 같은 항목들은 고립(actor-isolated)되어 있는 상태로 아무렇게나 접근할 수 없고, 아래와 같은 2가지 방법으로 접근이 가능하다.

### 1. self를 통한 접근

```swift
actor UniformStore {
    let store: String
    var koreanJersey: Double

    init(store: String, koreanJersey: Double) {
        self.store = store
        self.koreanJersey = koreanJersey
    }
}
```

- `self`를 통해 참조하면 오류가 나지 않는다.

```swift
extension UniformStore {
    enum StoreError: Error {
        case insufficientInventory
    }

    func send(amount: Double, to other: UniformStore) throws {
        if amount > self.koreanJersey {
            throw StoreError.insufficientInventory
        }

        self.koreanJersey = koreanJersey - amount
        other.koreanJersey = other.koreanJersey + amount // ❗️Actor-isolated property 'koreanJersey' can not be mutated on a non-isolated actor instance.
    }
}
```

- `self`가 아닌외부 객체가 참조를 하면 에러가 발생한다.

isolated 상태이기 때문에 외부에서 접근할 수 없고, 내부(`self`)에서 접근할 수 있다.

### 2. cross-actor reference

아래 2가지의 형태로 참조가 가능핟.

1. 불변의 형태(let) 참조

```swift
extension UniformStore {
    enum StoreError: Error {
        case insufficientInventory
    }

    func send(amount: Double, to other: UniformStore) throws {
        if amount > self.koreanJersey {
            throw StoreError.insufficientInventory
        }

        self.koreanJersey = koreanJersey - amount

        // let으로 선언된 store는 참조 가능
        let store = other.store
    }
}
```

- 불변값이므로 어떻게 참조해도 Data race가 발생하지 않는다.
1. 비동기 함수 호출

```swift
extension UniformStore {
    func addStock(amount: Double) async {
        assert(amount >= 0)
        koreanJersey = koreanJersey + amount
    }
}

extension UniformStore {
    enum StoreError: Error {
        case insufficientInventory
    }

    func send(amount: Double, to other: UniformStore) async throws {
        if amount > self.koreanJersey {
            throw StoreError.insufficientInventory
        }

        self.koreanJersey = koreanJersey - amount
        
        // 비동기 함수 호출로 접근 가능
        await other.addStock(amount: amount)
    }
}
```

- 비동기 함수로 접근하여 Race condition을 회피한다.

## 외부에서 접근하는 방법

### isolated 키워드

```swift
class TestActor {
    func addStock(amount: Double, to store: UniformStore) {
        assert(amount >= 0)
        store.koreanJersey = store.koreanJersey + amount // ❗️ Actor-isolated error
    }
}

class TestActor {
    func addStock(amount: Double, to store: isolated UniformStore) {
        assert(amount >= 0)
        store.koreanJersey = store.koreanJersey + amount
    }
}
```

- `isolated` 키워드를 추가함녀서 `addStock` 함수에 isolated한 특성을 갖게 되어 `UniformStore` 내부에 isolated한 변수에 접근할 수 있게 된다.

### nonisolated 키워드

```swift
extension UniformStore {
    nonisolated var greeting: String {
        "안녕하세요. \(self.store) 매장입니다."
    }
}

let pyeongTaekBranch = UniformStore(
    store: "평택",
    koreanJersey: 20
)

print(pyeongTaekBranch.greeting)
```

- `nonisolated`로 선언된 변수는 외부에서 별도의 처리없이 접근 가능하다.
- computed property만 `nonisolated`로 선언 가능하다.
- `nonisolated`로 선언된 프로퍼티는 isolated한 변수에 접근할 수 없다.(`koreanJersey`)

## Sendable

- Sendable은 해당 값이 concurrency 코드에서 안전하게 전달될 수 있도록 보장하는 프로토콜이다.
- Actor는 Sendable 프로토콜을 채택하고 있다.
- actor, let으로 선언된 프로퍼티, value type들은 모두 sendable하다.

```swift
struct UniformStore: Sendable {
    let store: String
    var koreanJersey: Double
    let ownerName: String
    let kiwi: Kiwi // ❗️Stored property 'kiwi' of 'Sendable'-conforming struct 'NikeStore' has non-sendable type 'kiwi'
    
    init(
        store: String,
        koreanJersey: Double,
        ownerName: String
    ) {
        self.store = store
        self.koreanJersey = koreanJersey
        self.ownerName = ownerName
    }
}

class Kiwi { }
```

- 단, 값 타입이더라도 내부에 모든 프로퍼티가 Sendable하지 않으면 에러가 발생한다.
- Kiwi를 actor로 선언하면 됨

```swift
final class UniformStore: Sendable {
    let store: String = "평택"
    let koreanJersey: Double = 20
}
```

- 클래스의 경우 final을 붙이고, 모든 변수를 불변값으로 만들어 주면 Sendable을 채택할 수 있다.
