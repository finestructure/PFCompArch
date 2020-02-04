//
//  Store.swift
//  CompArch
//
//  Created by Sven A. Schmidt on 22/01/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import Combine


public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]


public final class Store<Value, Action>: ObservableObject {
    @Published public private(set) var value: Value
    private let reducer: Reducer<Value, Action>
    private var viewCancellable: Cancellable?
    private var effectCancellables: Set<AnyCancellable> = []

    public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
        self.value = initialValue
        self.reducer = reducer
    }

    public func send(_ action: Action) {
        let effects = reducer(&value, action)
        effects.forEach { effect in
            var effectCancellable: AnyCancellable?
            var didComplete = false
            effectCancellable = effect.sink(
              receiveCompletion: { [weak self] _ in
                didComplete = true
                guard let effectCancellable = effectCancellable else { return }
                self?.effectCancellables.remove(effectCancellable)
              },
              receiveValue: self.send
            )
            if !didComplete, let effectCancellable = effectCancellable {
              effectCancellables.insert(effectCancellable)
            }
        }
    }

    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(self.value),
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
        }
        )
        localStore.viewCancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        return localStore
    }
}


public func combine<Value, Action>(_ reducers: Reducer<Value, Action>...) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducers.flatMap { $0(&value, action) }
        return effects
    }
}


public func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {

    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        let localEffects = reducer(&globalValue[keyPath: value], localAction)
        return localEffects.map { localEffect in
            localEffect.map { localAction -> GlobalAction in
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
            }.eraseToEffect()
        }
    }
}


public func logging<Value, Action>(_ reducer: @escaping Reducer<Value, Action>) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducer(&value, action)
        let newValue = value
        return [.fireAndForget {
            print("Action: \(action)")
            print("State:")
            dump(newValue)
            print("---")
              }] + effects
    }
}


// See https://github.com/pointfreeco/episode-code-samples/issues/33 for details

public struct Indexed<Value> {
    public var index: Int
    public var value: Value

    public init(index: Int, value: Value) {
        self.index = index
        self.value = value
    }
}


public func indexed<State, Action, GlobalState, GlobalAction>(
    reducer: @escaping Reducer<State, Action>,
    _ stateKeyPath: WritableKeyPath<GlobalState, [State]>,
    _ actionKeyPath: WritableKeyPath<GlobalAction, Indexed<Action>?>
) -> Reducer<GlobalState, GlobalAction> {
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: actionKeyPath] else { return [] }
        let index = localAction.index
        let localEffects = reducer(&globalValue[keyPath: stateKeyPath][index], localAction.value)
        return localEffects.map { localEffect in
            localEffect.map { localAction in
                var globalAction = globalAction
                globalAction[keyPath: actionKeyPath] = Indexed(index: index, value: localAction)
                return globalAction
            }.eraseToEffect()
        }
    }
}


public struct Identified<Value: Identifiable, Action> {
    public var id: Value.ID
    public var action: Action

    public init(id: Value.ID, action: Action) {
        self.id = id
        self.action = action
    }
}


public func identified<State: Identifiable, Action, GlobalState, GlobalAction>(
    reducer: @escaping Reducer<State, Action>,
    _ stateKeyPath: WritableKeyPath<GlobalState, [State]>,
    _ actionKeyPath: CasePath<GlobalAction, Identified<State, Action>>
) -> Reducer<GlobalState, GlobalAction> {
    return { globalValue, globalAction in
        guard let localAction = actionKeyPath.extract(from: globalAction) else { return [] }
        let id = localAction.id
        guard let index = globalValue[keyPath: stateKeyPath].firstIndex(where: { $0.id == id }) else { return [] }
        let localEffects = reducer(&globalValue[keyPath: stateKeyPath][index], localAction.action)
        return localEffects.map { localEffect in
            localEffect.map { localAction in
                return actionKeyPath.embed(Identified(id: id, action: localAction))
            }.eraseToEffect()
        }
    }
}


