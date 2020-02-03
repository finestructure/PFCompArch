//
//  ContentView.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 31/01/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import CompArch
import SwiftUI


struct ContentView: View {
    @ObservedObject var store1: Store<AppState1, AppAction1>
    @ObservedObject var store2: Store<AppState2, AppAction2>

    var body: some View {
        TabView {
            IdentifiedView(store1: self.store1).tabItem {
                Image(systemName: "faceid")
                Text("Identified")
            }
            IndexedView(store2: self.store2).tabItem {
                Image(systemName: "increase.indent")
                Text("Indexed")
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store1: .init(initialValue: .init(items: [1, 2, 3]), reducer: appReducer1),
            store2: .init(initialValue: .init(items: [2, 3, 4]), reducer: appReducer2)
        )
    }
}

