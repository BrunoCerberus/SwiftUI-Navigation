//
//  ContentView.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 20/11/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var selection = 1
    
    var body: some View {
        TabView(selection: $selection) {
            Text("One")
                .tabItem {
                    Text("One")
                }
                .tag(1)
            Text("Two")
                .tabItem {
                    Text("Two")
                }
                .tag(2)
            Text("Three")
                .tabItem {
                    Text("Three")
                }
                .tag(3)
        }
        .tabViewStyle(DefaultTabViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(selection: 2)
    }
}
