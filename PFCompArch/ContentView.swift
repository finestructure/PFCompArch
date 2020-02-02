//
//  ContentView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 31/01/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CompArch
import SwiftUI

typealias Item = Int

struct AppState {
    var items: [Item]
    func total() -> Int { items.reduce(0, +) }
    var cells: [CellState] {
        get { items.map(CellState.init) }
        set { items = newValue.map { $0.item } }
    }
}

enum AppAction {
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

struct CellState {
    var item: Item
}
enum CellAction {
    case plusTapped
    case minusTapped
}
let cellReducer: Reducer<CellState, CellAction> = { state, action in
    switch action {
        case .plusTapped:
            state.item += 1
            return []
        default:
            state.item -= 1
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
            Text("\(store.value.item)").frame(width: 30)
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
            ForEach(store.value.items.indices, id: \.self) { idx in
                Cell(store: self.store.view(value: { (appState) -> CellState in
                    appState.cells[idx]
                }, action: { (cellAction) -> AppAction in
                    .cell(Indexed(index: idx, value: cellAction))
                })
            )}
        }
    }
}


let appReducer: Reducer<AppState, AppAction> =
    indexed(reducer: cellReducer, \.cells, \.cell)


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .init(initialValue: .init(items: [1, 2, 3]), reducer: appReducer))
    }
}

