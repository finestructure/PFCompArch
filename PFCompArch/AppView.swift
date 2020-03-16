//
//  AppView.swift
//  Playgrounder
//
//  Created by Sven A. Schmidt on 12/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import CompArch
import HistoryView
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
        var historyView: HistoryView.State
    }

    enum Action {
        case contentView(ContentView.Action)
        case historyView(HistoryView.Action)
    }

    static var reducer: Reducer<State, Action> {
        let mainReducer: Reducer<State, Action> = { state, action in
            switch action {
                case .historyView(.newState(let data)):
                    state.contentView = data.flatMap(ContentView.State.init(from:)) ?? .init()
                    return []
                case .contentView(_), .historyView(_):
                    return []
            }
        }

        let broadcastReducer = broadcast(ContentView.reducer)

        let contentViewReducer = pullback(
            broadcastReducer,
            value: \State.contentView,
            action: /Action.contentView)

        let historyViewReducer = pullback(
            HistoryView.reducer,
            value: \State.historyView,
            action: /Action.historyView)

        return combine(mainReducer, contentViewReducer, historyViewReducer)
    }

    static func store() -> Store<State, Action> {
        Store(initialValue: .init( contentView: .init(), historyView: .init()),
              reducer: reducer)
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
