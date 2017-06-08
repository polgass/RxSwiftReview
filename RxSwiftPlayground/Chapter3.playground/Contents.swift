import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import RxSwift

// 1.) PUBLISHSUBJECT
example(of: "PublishSubject") {
  let subject = PublishSubject<String>()
  
  subject.onNext("Is anyone listening?")
  
  let subscriptionOne = subject.subscribe(onNext: { string in
    print(string)
  })
  
  subject.on(.next("1"))
  subject.onNext("2")
  
  let subscriptionTwo = subject.subscribe { event in
      print("2)", event.element ?? event)
  }
  
  subject.onNext("3")
  
  subscriptionOne.dispose()
  
  subject.onNext("4")
  
  // 1
  subject.onCompleted()
  
  // 2 
  subject.onNext("5")
  
  // 3
  subscriptionTwo.dispose()
  
  let disposeBag = DisposeBag()
  
  // 4
  subject
    .subscribe {
      print("3)", $0.element ?? $0)
    }
    .disposed(by: disposeBag)
  
  subject.onNext("?")
}

// 2.) BEHAVIORSUBJECT
// 1
enum MyError: Error {
  case anError
}
// 2
func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
  print(label, event.element ?? event.error ?? event)
}
// 3
example(of: "BehaviorSubject") {
  // 4
  let subject = BehaviorSubject(value: "Initial value")
  let disposeBag = DisposeBag()
  
  subject.onNext("X")
  
  subject
    .subscribe {
      print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)
  
  // 1
  subject.onError(MyError.anError)
  
  // 2
  subject
    .subscribe {
      print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)
}

// 3.) REPLAYSUBJECT
example(of: "ReplaySubject") {
  // 1
  let subject = ReplaySubject<String>.create(bufferSize: 2)
  let disposeBag = DisposeBag()
  // 2
  subject.onNext("1")
  subject.onNext("2")
  subject.onNext("3")
  // 3
  subject
    .subscribe {
      print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)
  subject
    .subscribe {
      print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)
  
  subject.onNext("4")
  
  subject.onError(MyError.anError)
  
//  subject.dispose()
  
  subject
    .subscribe {
      print(label: "3)", event: $0)
    }
    .disposed(by: disposeBag)
}

// 4.) VARIABLE
example(of: "Variable") {
  // 1
  var variable = Variable("Initial value")
  let disposeBag = DisposeBag()
  // 2
  variable.value = "New initial value"
  // 3
  variable.asObservable()
    .subscribe {
      print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)
  
  // 1
  variable.value = "1"
  // 2
  variable.asObservable()
    .subscribe {
      print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)
  // 3
  variable.value = "2"
}

// CHALLENGES

example(of: "Challenge 1 - PublishSubject") {
  
  let disposeBag = DisposeBag()
  
  let dealtHand = PublishSubject<[(String, Int)]>()
  
  func deal(_ cardCount: UInt) {
    var deck = cards
    var cardsRemaining: UInt32 = 52
    var hand = [(String, Int)]()
    
    for _ in 0..<cardCount {
      let randomIndex = Int(arc4random_uniform(cardsRemaining))
      hand.append(deck[randomIndex])
      deck.remove(at: randomIndex)
      cardsRemaining -= 1
    }
    
    // Add code to update dealtHand here
  
    if points(for: hand) > 21 {
      dealtHand.onError(HandError.busted)
    } else {
      dealtHand.onNext(hand)
    }
  }

  // Add subscription to dealtHand here
  
  dealtHand
    .subscribe(onNext: { h in
      print(cardString(for: h))
    }, onError: { error in
      print(error)
    })
    .disposed(by: disposeBag)
  
  deal(3)
}

example(of: "Challenge 2 - Variable") {
  
  enum UserSession {
    
    case loggedIn, loggedOut
  }
  
  enum LoginError: Error {
    
    case invalidCredentials
  }
  
  let disposeBag = DisposeBag()
  
  // Create userSession Variable of type UserSession with initial value of .loggedOut
  
  var userSession: Variable<UserSession> = Variable(.loggedOut)
  
  
  // Subscribe to receive next events from userSession
  
  userSession
    .asObservable()
    .subscribe(onNext: { session in
      print(session)
    })
    .disposed(by: disposeBag)
  
  
  func logInWith(username: String, password: String, completion: (Error?) -> Void) {
    guard username == "johnny@appleseed.com",
      password == "appleseed"
      else {
        completion(LoginError.invalidCredentials)
        return
    }
    
    // Update userSession
    userSession.value = .loggedIn
  }
  
  func logOut() {
    // Update userSession
    userSession.value = .loggedOut
  }
  
  func performActionRequiringLoggedInUser(_ action: () -> Void) {
    // Ensure that userSession is loggedIn and then execute action()
    if userSession.value == .loggedIn {
      action()
    }
  }
  
  for i in 1...2 {
    let password = i % 2 == 0 ? "appleseed" : "password"
    
    logInWith(username: "johnny@appleseed.com", password: password) { error in
      guard error == nil else {
        print(error!)
        return
      }
      
      print("User logged in.")
    }
    
    performActionRequiringLoggedInUser {
      print("Successfully did something only a logged in user can do.")
    }
  }
}


