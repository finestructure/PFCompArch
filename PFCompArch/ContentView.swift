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
    var body: some View {
        TabView {
            IdentifiedView(store: Sample.identifiedViewStore).tabItem {
                Image(systemName: "faceid")
                Text("Identified")
            }
            IndexedView(store: Sample.indexedViewStore).tabItem {
                Image(systemName: "increase.indent")
                Text("Indexed")
            }
            ListView(store: Sample.listViewStore).tabItem {
                Image(systemName: "list.dash")
                Text("List")
            }
        }
    }
}


struct Sample {}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

