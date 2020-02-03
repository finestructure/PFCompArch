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
    @ObservedObject var identifiedViewStore: Store<IdentifiedView.State, IdentifiedView.Action>
    @ObservedObject var store2: Store<AppState2, AppAction2>

    var body: some View {
        TabView {
            IdentifiedView(store: self.identifiedViewStore).tabItem {
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


struct Sample {}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            identifiedViewStore: Sample.identifiedViewStore,
            store2: .init(initialValue: .init(items: [2, 3, 4]), reducer: appReducer2)
        )
    }
}

