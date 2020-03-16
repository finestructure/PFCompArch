//
//  ListView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CasePaths
import CompArch
import SwiftUI


typealias IdentifiedListCell = Identified<ListCell.State, ListCell.Action>


extension ListView {
    struct State: Codable {
        var items: [Item]
        var cells: [ListCell.State] {
            get { items.map(ListCell.State.init) }
            set { items = newValue.map { $0.item } }
        }
    }

    enum Action {
        case cell(IdentifiedListCell)
        case delete(IndexSet)
    }

    static var reducer: Reducer<State, Action> {
        let detailReducer: Reducer<State, Action> = identified(reducer: ListCell.reducer, \.cells, /Action.cell)
        let mainReducer: Reducer<State, Action> = { state, action in
            switch action {
                case .cell((let id, .deleteTapped)):
                    state.items.removeAll(where: { $0.id == id })
                    return []
                case .delete(let indexSet):
                    indexSet.forEach { state.items.remove(at: $0) }
                    return []
            }
        }
        return combine(detailReducer, mainReducer)
    }
}


struct ListView: View {
    @ObservedObject var store: Store<State, Action>

    func cellView(for item: Item) -> AnyView {
        guard let cell = store.value.items.first(where: { $0.id == item.id }) else {
            return AnyView(EmptyView())
        }
        return AnyView(
            ListCell(store: self.store.view(
                value: { _ in .init(item: cell) },
                action: { .cell(IdentifiedListCell(id: cell.id, action: $0)) }))
        )
    }

    var body: some View {
        List {
            ForEach(store.value.items) { cell in
                self.cellView(for: cell)
            }
            .onDelete { (indexSet) in
                self.store.send(.delete(indexSet))
            }
        }
    }
}


extension ListView {
    static func store(items: [Item]) -> Store<State, Action> {
        let initial = ListView.State(items: items)
        return Store(initialValue: initial, reducer: reducer)
    }
}


struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(store: ListView.store(items: [1, 2, 3]))
    }
}
