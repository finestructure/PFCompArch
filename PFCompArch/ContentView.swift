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
    }

    enum Action {
        case identifiedView(IdentifiedView.Action)
        case indexedView(IndexedView.Action)
        case listView(ListView.Action)
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

        return combine(identifiedViewReducer, indexedViewReducer, listViewReducer)
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
        let initial = ContentView.State(identifiedView: .init(items: items),
                                        indexedView: .init(items: items),
                                        listView: .init(items: items))
        return Store(initialValue: initial, reducer: reducer)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: ContentView.store(items: [1, 2, 3]))
    }
}


// MARK:- State surfing

extension ContentView.State: StateInitializable {
    init() {
        let items: [Item] = [1, 2, 3]
        self.identifiedView = .init(items: items)
        self.indexedView = .init(items: items)
        self.listView = .init(items: items)
    }
}


extension ContentView: StateSurfable {
    static func body(store: Store<State, Action>) -> Self {
        ContentView(store: store)
    }
}
