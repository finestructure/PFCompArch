//
//  ListView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import CompArch
import SwiftUI


extension ListView {
    struct State {
        var items: [Item]
        var cells: [CellView.State] {
            get { items.map(CellView.State.init) }
            set { items = newValue.map { $0.item } }
        }
    }

    enum Action {
        case cell(Identified<CellView.State, CellView.Action>)
        case delete(IndexSet)
    }

    static fileprivate var reducer: Reducer<State, Action> {
        let detailReducer: Reducer<State, Action> = identified(reducer: CellView.reducer, \.cells, /Action.cell)
        let mainReducer: Reducer<State, Action> = { state, action in
            switch action {
                case .cell(_):
                    return []
                case .delete(let indexSet):
                    indexSet.forEach { state.items.remove(at: $0) }
                    return []
            }
        }
        return combine(detailReducer, mainReducer)
    }
}


struct ListView: View {
    @ObservedObject var store: Store<State, Action>

    var body: some View {
        List {
            ForEach(store.value.items) {
                Text("\($0.id) | \($0.value)")
            }
            .onDelete { (indexSet) in
                self.store.send(.delete(indexSet))
            }
        }
    }
}


extension Sample {
    static var listViewStore: Store<ListView.State, ListView.Action> {
        .init(initialValue: .init(items: [1, 2, 3]), reducer: ListView.reducer)
    }
}


struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(store: Sample.listViewStore)
    }
}
