# Swift Concurrency

- [Async/Await](AsyncAwait.md)
- [AsyncSequence](AsyncSequence.md)
- [Structured Concurrency](StructuredConcurrency.md)
- [Actor](Actor.md)
- [Eliminate data races using Swift Concurrency](EliminateDataRaces.md)

## Swift Concurrency의 등장 배경

### GCD(Grand Central Dispatch)

- iOS, macOS, watchOS, tvOS등에서 동시성 실행을 제공하는 프로그래밍 언어적 요소, 런타임 라이브러리 등이다.
- GCD의 개념으로 동시성 프로그래밍을 제공하는 API가 `DispatchQueue`이다.

### GCD의 한계

- 각 스레드가 data race를 유발할 위험이 있다.
- Thread Explosion
    - Thread가 과도하게 많이 만들어지며 context switching이 너무 자주 일어나는 문제가 발생할 수 있다.
    ex) 1개의 코어에서 100개의 thread가 생성되면, 최소 100회의 context switching이 일어난다.
    - context switching은 오버헤드를 발생시켜 성능 저하의 원인이 된다.
    - 하나의 큐에서 너무 오래 걸리는 작업을 하면 cpu의 한계로 다른 작업이 수행되지 않을 가능성이 있다.
        
        ```swift
        func explodingCPU() {
            let queue = DispatchQueue(label: "CPU_EXPLODED!", attributes: .concurrent)
            
            for n in 0..<1000 {
                queue.async {
                    print(Thread.current)
                    while true { }
                }
            }
        }
        ```
        
        ![Untitled](Images/swift_concurrency_2.png)
        
        - 실제로 일부 print가 호출되지 않음.

### Swift Concurrency로 극복

- Swift Concurrency는 단일 thread에서 동작한다. 즉, 하나의 코어가 하나의 thread를 실행하도록 보장한다.
- `await`으로 중단됐을 때, CPU가 컨텍스트 스위칭을 해서 다른 스레드를 불러오는 것이 아니라 같은 스레드에서 다음 함수를 실행시킨다.

![Untitled](Images/swift_concurrency_1.png)
