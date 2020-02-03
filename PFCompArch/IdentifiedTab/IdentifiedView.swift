//
//  IdentifiedView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CompArch
import SwiftUI


struct AppState1 {
    var items: [Item]
    func total() -> Int { items.reduce(0, { $0 + $1.value }) }
    var cells: [CellState] {
        get { items.map(CellState.init) }
        set { items = newValue.map { $0.item } }
    }
}


enum AppAction1 {
    case cell(Identified<CellState, CellAction>)

    var cell: Identified<CellState, CellAction>? {
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


let appReducer1: Reducer<AppState1, AppAction1> =
identified(reducer: cellReducer, \.cells, \.cell)


struct IdentifiedView: View {
    @ObservedObject var store1: Store<AppState1, AppAction1>

    var body: some View {
        VStack {
            Text("Identified").font(.title)
            Text("Total: \(store1.value.total())")
            ForEach(store1.value.cells) { cell in
                CellView(store: self.store1.view(value: { $0.cells.first(where: { $0.id == cell.id })! },
                                                 action: { .cell(Identified(id: cell.id, action: $0)) }
                    )
                )}
        }
    }
}


struct IdentifiedView_Previews: PreviewProvider {
    static var previews: some View {
        IdentifiedView(
            store1: .init(initialValue: .init(items: [1, 2, 3]), reducer: appReducer1)
        )
    }
}
