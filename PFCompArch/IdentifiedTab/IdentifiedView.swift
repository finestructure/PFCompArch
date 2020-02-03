//
//  IdentifiedView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CompArch
import SwiftUI


extension IdentifiedView {
    struct State {
        var items: [Item]
        func total() -> Int { items.reduce(0, { $0 + $1.value }) }
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


struct IdentifiedView: View {
    @ObservedObject var store: Store<State, Action>

    var body: some View {
        VStack {
            Text("Identified").font(.title)
            Text("Total: \(store.value.total())")
            ForEach(store.value.cells) { cell in
                CellView(store: self.store.view(value: { $0.cells.first(where: { $0.id == cell.id })! },
                                                action: { .cell(Identified(id: cell.id, action: $0)) }
                    )
                )}
        }
    }
}


extension Sample {
    static var identifiedViewStore: Store<IdentifiedView.State, IdentifiedView.Action> {
        .init(initialValue: .init(items: [1, 2, 3]), reducer: IdentifiedView.reducer)
    }
}


struct IdentifiedView_Previews: PreviewProvider {
    static var previews: some View {
        IdentifiedView(store: Sample.identifiedViewStore)
    }
}
