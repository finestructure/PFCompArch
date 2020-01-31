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
    var items: [String]
}

enum AppAction {
    case itemTapped
}

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>

    var body: some View {
        List(store.value.items, id: \.self) {
            Text($0)
        }
    }
}

let appReducer: Reducer<AppState, AppAction> = { (value, action) in
    return []
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .init(initialValue: .init(items: ["a", "b", "c"]), reducer: appReducer))
    }
}
