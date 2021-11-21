//
//  ContentView.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 20/11/21.
//

import SwiftUI

enum Tab: Equatable {
    case one, two, three
}

final class AppViewModel: ObservableObject {
    @Published var selectedTab: Tab
    
    init(selectedTab: Tab) {
        self.selectedTab = selectedTab
    }
}

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Button(action: { viewModel.selectedTab = .three }) {
                Text("Goes to Tab 3")
            }
                .tabItem {
                    Text("One")
                }
                .tag(Tab.one)
            Text("Two")
                .tabItem {
                    Text("Two")
                }
                .tag(Tab.two)
            Text("Three")
                .tabItem {
                    Text("Three")
                }
                .tag(Tab.three)
        }
        .tabViewStyle(DefaultTabViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppViewModel(selectedTab: .one))
    }
}
