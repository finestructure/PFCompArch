//
//  IndexedView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CompArch
import SwiftUI


typealias AppState2 = IdentifiedView.State


enum AppAction2 {
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


let appReducer2: Reducer<AppState2, AppAction2> =
indexed(reducer: cellReducer, \.cells, \.cell)


struct IndexedView: View {
    @ObservedObject var store2: Store<AppState2, AppAction2>

    var body: some View {
        VStack {
            Text("Indexed").font(.title)
            Text("Total: \(store2.value.total())")
            ForEach(store2.value.items.indices) { idx in
                CellView(store:
                    self.store2.view(
                        value: { $0.cells[idx] },
                        action: { .cell(Indexed(index: idx, value: $0)) })
                )
            }
        }
    }
}

struct IndexedView_Previews: PreviewProvider {
    static var previews: some View {
        IndexedView(
            store2: .init(initialValue: .init(items: [1, 2, 3]), reducer: appReducer2)
        )
    }
}
