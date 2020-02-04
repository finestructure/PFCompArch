//
//  CellView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CompArch
import SwiftUI


extension CellView {
    struct State: Identifiable {
        var id: UUID { item.id }
        var item: Item
    }


    enum Action {
        case plusTapped
        case minusTapped
    }


    static var reducer: Reducer<State, Action> {
        return { state, action in
            switch action {
                case .plusTapped:
                    state.item.value += 1
                    return []
                default:
                    state.item.value -= 1
                    return []
            }
        }
    }
}


struct CellView: View {
    @ObservedObject var store: Store<State, Action>

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


struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(
            store: .init(initialValue: .init(item: 3),
                         reducer: CellView.reducer)
        )
    }
}
