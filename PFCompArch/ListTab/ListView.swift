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


struct ListCell: View {
    @ObservedObject var store: Store<State, Action>

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(store.value.id)")
                Text("\(store.value.item.value)")
            }
            Spacer()
            Button(action: { self.store.send(.deleteTapped) },
                   label: {
                    Image(systemName: "multiply.circle")
                        .font(.title)
                        .foregroundColor(Color.red)
            })
        }
    }

    struct State {
        var id: UUID { item.id }
        var item: Item
    }

    enum Action {
        case deleteTapped
    }

    static var reducer: Reducer<State, Action> = { state, action in
        switch action {
            case .deleteTapped:
                return []
        }
    }
}


extension ListView {
    struct State {
        var items: [Item]
        var cells: [ListCell.State] {
            get { items.map(ListCell.State.init) }
            set { items = newValue.map { $0.item } }
        }
    }

    enum Action {
        case cell(Indexed<ListCell.Action>)
        case delete(IndexSet)
    }

    static fileprivate var reducer: Reducer<State, Action> {
        let detailReducer: Reducer<State, Action> = indexed(reducer: ListCell.reducer, \.cells, /Action.cell)
        let mainReducer: Reducer<State, Action> = { state, action in
            switch action {
                case .cell(let indexedAction):
                    if case .deleteTapped = indexedAction.value {
                        state.items.remove(at: indexedAction.index)
                    }
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

    var body: some View {
        List {
            ForEach(store.value.items.indices) { idx in
                ListCell(store: self.store.view(
                    value: { $0.cells[idx] },
                    action: { .cell(Indexed(index: idx, value: $0)) } ))
            }
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
