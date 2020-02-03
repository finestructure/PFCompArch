//
//  IndexedView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

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

        var cell: Indexed<CellView.Action>? {
            get {
                guard case let .cell(value) = self else { return nil }
                return value
            }
            set {
                guard case .cell = self, let newValue = newValue else { return }
                self = .cell(newValue)
            }
        }
    }

    static fileprivate var reducer: Reducer<State, Action> {
        indexed(reducer: CellView.reducer, \.cells, \.cell)
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
                        action: { .cell(Indexed(index: idx, value: $0)) })
                )
            }
        }
    }
}


extension Sample {
    static var indexedViewStore: Store<IndexedView.State, IndexedView.Action> {
        .init(initialValue: .init(items: [2, 3, 4]), reducer: IndexedView.reducer)
    }
}


struct IndexedView_Previews: PreviewProvider {
    static var previews: some View {
        IndexedView(store: Sample.indexedViewStore)
    }
}
