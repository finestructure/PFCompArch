//
//  ContentView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 31/01/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import CompArch
import HistoryTransceiver
import SwiftUI


extension ContentView {
    struct State: Codable {
        var identifiedView: IdentifiedView.State
        var indexedView: IndexedView.State
        var listView: ListView.State

        init(items: [Item]) {
            self.identifiedView = .init(items: items)
            self.indexedView = .init(items: items)
            self.listView = .init(items: items)
        }

        init?(from data: Data) {
            guard let state = try? JSONDecoder().decode(Self.self, from: data) else { return nil }
            self = state
        }
    }

    enum Action {
        case identifiedView(IdentifiedView.Action)
        case indexedView(IndexedView.Action)
        case listView(ListView.Action)
        case updateState(Data?)
    }

    static var reducer: Reducer<State, Action> {
        let identifiedViewReducer: Reducer<State, Action> = pullback(
            IdentifiedView.reducer,
            value: \State.identifiedView,
            action: /Action.identifiedView)

        let indexedViewReducer: Reducer<State, Action> = pullback(
            IndexedView.reducer,
            value: \State.indexedView,
            action: /Action.indexedView)

        let listViewReducer: Reducer<State, Action> = pullback(
            ListView.reducer,
            value: \State.listView,
            action: /Action.listView)

        let historyReducer: Reducer<State, Action> = { state, action in
            switch action {
                case .updateState(let data):
                    // receiving a nil value signals resetting to initial state
                    state = data.flatMap(ContentView.State.init(from:)) ?? initialState
                    return []
                default:
                    return []
            }
        }

        // FIXME: somehow, despite constraining broadcast to only work on the child reducers here
        // it still transmits the .updateState() action, which we don't really want fed back
        let combinedReducer = broadcast(combine(identifiedViewReducer, indexedViewReducer, listViewReducer))

        return combine(combinedReducer, historyReducer)
    }
}


struct ContentView: View {
    @ObservedObject var store: Store<State, Action>

    var body: some View {
        TabView {
            IdentifiedView(store: self.store.view(value: { $0.identifiedView },
                                                  action: { .identifiedView($0) })
            ).tabItem {
                Image(systemName: "faceid")
                Text("Identified")
            }
            IndexedView(store: self.store.view(value: { $0.indexedView },
                                               action: { .indexedView($0) })
            ).tabItem {
                Image(systemName: "increase.indent")
                Text("Indexed")
            }
            ListView(store: self.store.view(value: { $0.listView },
                                            action: { .listView($0) })
            ).tabItem {
                Image(systemName: "list.dash")
                Text("List")
            }
        }
    }
}


extension ContentView {
    static func store(items: [Item]) -> Store<State, Action> {
        let initial = ContentView.State(items: items)
        return Store(initialValue: initial, reducer: reducer)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: ContentView.store(items: [1, 2, 3]))
    }
}

