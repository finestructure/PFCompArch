//
//  Effect.swift
//  CompArch
//
//  Created by Sven A. Schmidt on 22/01/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import Combine


public struct Effect<Output>: Publisher {
    public typealias Failure = Never
    let publisher: AnyPublisher<Output, Failure>

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        publisher.receive(subscriber: subscriber)
    }
}


extension Effect {
  public static func fireAndForget(work: @escaping () -> Void) -> Effect {
    return Deferred { () -> Empty<Output, Never> in
      work()
      return Empty(completeImmediately: true)
    }
    .eraseToEffect()
  }
}


extension Effect {
  public static func sync(work: @escaping () -> Output) -> Effect {
    return Deferred { Just(work()) }.eraseToEffect()
  }
}


