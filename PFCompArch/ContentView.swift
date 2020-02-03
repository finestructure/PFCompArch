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
    @ObservedObject var indexedViewStore: Store<IndexedView.State, IndexedView.Action>

    var body: some View {
        TabView {
            IdentifiedView(store: self.identifiedViewStore).tabItem {
                Image(systemName: "faceid")
                Text("Identified")
            }
            IndexedView(store: self.indexedViewStore).tabItem {
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
            indexedViewStore: Sample.indexedViewStore
        )
    }
}

