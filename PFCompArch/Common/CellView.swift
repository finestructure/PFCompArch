//
//  CellView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
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


struct CellView: View {
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


//struct CellView_Previews: PreviewProvider {
//    static var previews: some View {
//        CellView()
//    }
//}
