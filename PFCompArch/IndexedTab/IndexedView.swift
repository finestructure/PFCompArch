//
//  IndexedView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import CompArch
import SwiftUI


extension IndexedView {
    struct State {
        var items: [Item]
        func total() -> Int { items.reduce(0, { $0 + $1.value }) }
        var cells: [CellView.State] {
            get { items.map(CellView.State.init) }
            set { items = newValue.map { $0.item } }
        }
    }

    enum Action {
        case cell(Indexed<CellView.Action>)
    }

    static var reducer: Reducer<State, Action> {
        indexed(reducer: CellView.reducer, \.cells, /Action.cell)
    }
}


struct IndexedView: View {
    @ObservedObject var store: Store<State, Action>

    var body: some View {
        VStack {
            Text("Indexed").font(.title)
            Text("Total: \(store.value.total())")
            ForEach(store.value.items.indices) { idx in
                CellView(store:
                    self.store.view(
                        value: { $0.cells[idx] },
                        action: { .cell(Indexed(index: idx, action: $0)) })
                )
            }
        }
    }
}


extension IndexedView {
    static func store(items: [Item]) -> Store<State, Action> {
        let initial = IndexedView.State(items: items)
        return Store(initialValue: initial, reducer: reducer)
    }
}


struct IndexedView_Previews: PreviewProvider {
    static var previews: some View {
        IndexedView(store: IndexedView.store(items: [2, 3, 4]))
    }
}
