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
