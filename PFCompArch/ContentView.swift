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

typealias AppState2 = AppState1

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
    @ObservedObject var store1: Store<AppState1, AppAction1>
    @ObservedObject var store2: Store<AppState2, AppAction2>

    var body: some View {
        VStack {
            VStack {
                Text("Identified").font(.title)
                Text("Total: \(store1.value.total())")
                ForEach(store1.value.cells) { cell in
                    Cell(store: self.store1.view(value: { $0.cells.first(where: { $0.id == cell.id })! },
                                                 action: { .cell(Identified(id: cell.id, action: $0)) }
                        )
                    )}
            }
            VStack {
                Text("Indexed").font(.title)
                Text("Total: \(store2.value.total())")
                ForEach(store2.value.items.indices) { idx in
                    Cell(store:
                        self.store2.view(
                            value: { $0.cells[idx] },
                            action: { .cell(Indexed(index: idx, value: $0)) })
                    )
                }
            }.padding(.top)
        }
    }
}

let appReducer1: Reducer<AppState1, AppAction1> =
    identified(reducer: cellReducer, \.cells, \.cell)
let appReducer2: Reducer<AppState2, AppAction2> =
    indexed(reducer: cellReducer, \.cells, \.cell)


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store1: .init(initialValue: .init(items: [1, 2, 3]), reducer: appReducer1),
            store2: .init(initialValue: .init(items: [2, 3, 4]), reducer: appReducer2)
        )
    }
}

