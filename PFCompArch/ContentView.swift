//
//  ContentView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 31/01/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import CompArch
import SwiftUI


extension ContentView {
    struct State {
        var identifiedView: IdentifiedView.State
    }

    enum Action {
        case identifiedView(IdentifiedView.Action)
    }

    static var reducer: Reducer<State, Action> {
        let identifiedViewReducer: Reducer<State, Action> = pullback(
            IdentifiedView.reducer,
            value: \State.identifiedView,
            action: /Action.identifiedView)

        return identifiedViewReducer
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
            IndexedView(store: Sample.indexedViewStore).tabItem {
                Image(systemName: "increase.indent")
                Text("Indexed")
            }
            ListView(store: Sample.listViewStore).tabItem {
                Image(systemName: "list.dash")
                Text("List")
            }
        }
    }
}


extension ContentView {
    static func store(items: [Item]) -> Store<State, Action> {
        let initial = ContentView.State(identifiedView: .init(items: items))
        return Store(initialValue: initial, reducer: reducer)
    }
}


struct Sample {}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: ContentView.store(items: [1, 2, 3]))
    }
}

