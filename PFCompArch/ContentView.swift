//
//  ContentView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 31/01/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CompArch
import SwiftUI

struct AppState {
    var items: [Int]
    func total() -> Int { items.reduce(0, +) }
}

enum AppAction {
    case cell(CellAction)
}

struct CellState {
    var item: Int
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
            ForEach(store.value.items, id: \.self) { item in
                Cell(store: self.store.view(value: { (appState) -> CellState in
                    // normally we'd project out from appState but we can't,
                    // because it depends on the list index - using item directly instead
                    .init(item: item)
                }, action: { (cellAction) -> AppAction in
                    .cell(cellAction)
                })
            )}
        }
    }
}

let appReducer: Reducer<AppState, AppAction> = pullback(
    cellReducer,
    value: ???,  // requires key path from AppState to a specific CellState[idx] but we don't have idx!
    action: WritableKeyPath<GlobalAction, LocalAction?>
)

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .init(initialValue: .init(items: [1, 2, 3]), reducer: appReducer))
    }
}
