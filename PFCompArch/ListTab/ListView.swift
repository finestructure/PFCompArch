//
//  ListView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

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

        var cell: Identified<CellView.State, CellView.Action>? {
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
        identified(reducer: CellView.reducer, \.cells, \.cell)
    }
}


struct ListView: View {
    @ObservedObject var store: Store<State, Action>

    var body: some View {
        List(store.value.items) {
            Text("\($0.id) | \($0.value)")
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
