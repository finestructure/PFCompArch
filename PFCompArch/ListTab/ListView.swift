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

    struct State: Identifiable {
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
        case cell(Identified<ListCell.State, ListCell.Action>)
        case delete(IndexSet)
    }

    static fileprivate var reducer: Reducer<State, Action> {
        let detailReducer: Reducer<State, Action> = identified(reducer: ListCell.reducer, \.cells, /Action.cell)
        let mainReducer: Reducer<State, Action> = { state, action in
            switch action {
                case .cell(let identifiedAction):
                    // FIXME: use tuple to destructure https://github.com/pointfreeco/episode-code-samples/issues/33#issuecomment-549882781
                    if case .deleteTapped = identifiedAction.action {
                        state.items.removeAll(where: { $0.id == identifiedAction.id })
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

    func cellView(for item: Item) -> AnyView {
        guard let cell = store.value.items.first(where: { $0.id == item.id }) else {
            return AnyView(EmptyView())
        }
        return AnyView(
            ListCell(store: self.store.view(
                value: { _ in .init(item: cell) },
                action: { .cell(Identified(id: cell.id, action: $0)) }))
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
