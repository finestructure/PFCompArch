//
//  AppView.swift
//  Playgrounder
//
//  Created by Sven A. Schmidt on 12/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import CompArch
import SwiftUI


struct AppView: View {
    @ObservedObject var store: Store<State, Action>

    var body: some View {
        ContentView(store: store.view(value: { $0.contentView },
                                      action: { .contentView($0) }))
    }

    init(store: Store<State, Action>) {
        self.store = store
    }
}


extension AppView {
    struct State {
        var contentView: ContentView.State
    }

    enum Action {
        case contentView(ContentView.Action)
        case updateState(Data?)
    }

    static var reducer: Reducer<State, Action> {
        let mainReducer: Reducer<State, Action> = { state, action in
            switch action {
                case .contentView:
                    return []
                case .updateState(let data):
                    state.contentView = data.flatMap(ContentView.State.init(from:)) ?? .init()
                    return []
            }
        }

        let broadcastReducer = broadcast(ContentView.reducer)

        let contentViewReducer = pullback(
            broadcastReducer,
            value: \State.contentView,
            action: /Action.contentView)

        return combine(mainReducer, contentViewReducer)
    }

    static func store() -> Store<State, Action> {
        let initial = State(contentView: .init())
        return Store(initialValue: initial, reducer: reducer)
    }
}


extension ContentView.State {
    init?(from data: Data) {
        guard let state = try? JSONDecoder().decode(Self.self, from: data) else { return nil }
        self = state
    }

    init() {
        let items: [Item] = [1, 2, 3]
        self.identifiedView = .init(items: items)
        self.indexedView = .init(items: items)
        self.listView = .init(items: items)
    }
}
