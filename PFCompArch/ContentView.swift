//
//  ContentView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 31/01/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CompArch
import SwiftUI

struct Item: Identifiable {
    let id: UUID
    var value: Int
}

extension Item: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self.id = UUID()
        self.value = value
    }
}

struct AppState {
    var items: [Item]
    func total() -> Int { items.reduce(0, { $0 + $1.value }) }
    var cells: [CellState] {
        get { items.map(CellState.init) }
        set { items = newValue.map { $0.item } }
    }
}

enum AppAction {
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

struct CellState: Identifiable {
    var id: UUID { item.id }
    var item: Item
}
enum CellAction {
    case plusTapped
    case minusTapped
}
let cellReducer: Reducer<CellState, CellAction> = { state, action in
    switch action {
        case .plusTapped:
            state.item.value += 1
            return []
        default:
            state.item.value -= 1
            return []
    }
}

struct Cell: View {
    @ObservedObject var store: Store<CellState, CellAction>

    var body: some View {
        HStack {
            Button(action: {
                self.store.send(.minusTapped)
            }) {
                Image(systemName: "minus.circle.fill")
            }
            Text("\(store.value.item.value)").frame(width: 30)
            Button(action: {
                self.store.send(.plusTapped)
            }) {
                Image(systemName: "plus.circle.fill")
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>

    var body: some View {
        VStack {
            Text("Total: \(store.value.total())")
            ForEach(store.value.cells) { cell in
                Cell(store: self.store.view(value: { $0.cells.first(where: { $0.id == cell.id })! },
                                            action: { .cell(Identified(id: cell.id, action: $0)) }
                    )
            )}
        }
    }
}

let stateKP = \AppState.cells
let actionKP = \AppAction.cell
let appReducer: Reducer<AppState, AppAction> =
    identified(reducer: cellReducer, \AppState.cells, \AppAction.cell)


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .init(initialValue: .init(items: [1, 2, 3]), reducer: appReducer))
    }
}

