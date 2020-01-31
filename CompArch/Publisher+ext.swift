//
//  Publisher+ext.swift
//  CompArch
//
//  Created by Sven A. Schmidt on 22/01/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import Combine


func absurd<A>(_ never: Never) -> A {}


extension Publisher where Failure == Never {
  public func eraseToEffect() -> Effect<Output> {
    return Effect(publisher: self.eraseToAnyPublisher())
  }
}


extension Publisher where Output == Never, Failure == Never {
  public func fireAndForget<A>() -> Effect<A> {
    return self.map(absurd).eraseToEffect()
  }
}
