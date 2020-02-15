//
//  ListCell.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 15/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

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
            Image(systemName: "multiply.circle")
                .font(.title)
                .foregroundColor(Color.red)
                .onTapGesture { self.store.send(.deleteTapped) }
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


extension Sample {
    static var listCellStore: Store<ListCell.State, ListCell.Action> {
        .init(initialValue: .init(item: 42), reducer: ListCell.reducer)
    }
}

struct ListCell_Previews: PreviewProvider {
    static var previews: some View {
        ListCell(store: Sample.listCellStore)
    }
}
