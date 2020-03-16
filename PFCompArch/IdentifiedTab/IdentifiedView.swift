//
//  IdentifiedView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import CompArch
import SwiftUI


typealias IdentifiedCell = Identified<CellView.State, CellView.Action>


extension IdentifiedView {
    struct State: Codable {
        var items: [Item]
        func total() -> Int { items.reduce(0, { $0 + $1.value }) }
        var cells: [CellView.State] {
            get { items.map(CellView.State.init) }
            set { items = newValue.map { $0.item } }
        }
    }

    enum Action {
        case cell(IdentifiedCell)
    }

    static var reducer: Reducer<State, Action> {
        identified(reducer: CellView.reducer, \.cells, /Action.cell)
    }
}


struct IdentifiedView: View {
    @ObservedObject var store: Store<State, Action>

    var body: some View {
        VStack {
            Text("Identified").font(.title)
            Text("Total: \(store.value.total())")
            ForEach(store.value.cells) { cell in
                CellView(store: self.store.view(value: { $0.cells.first(where: { $0.id == cell.id })! },
                                                action: { .cell(IdentifiedCell(id: cell.id, action: $0)) }
                    )
                )}
        }
    }
}


extension IdentifiedView {
    static func store(items: [Item]) -> Store<State, Action> {
        let initial = IdentifiedView.State(items: items)
        return Store(initialValue: initial, reducer: reducer)
    }
}


struct IdentifiedView_Previews: PreviewProvider {
    static var previews: some View {
        IdentifiedView(store: IdentifiedView.store(items: [1, 2, 3]))
    }
}
