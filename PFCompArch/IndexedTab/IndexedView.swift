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
    typealias State = IdentifiedView.State

    enum Action {
        case cell(Indexed<CellAction>)

        var cell: Indexed<CellAction>? {
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

    static var reducer: Reducer<State, Action> {
        indexed(reducer: cellReducer, \.cells, \.cell)
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
