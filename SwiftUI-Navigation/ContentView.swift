//
//  ContentView.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 20/11/21.
//

import Parsing
import SwiftUI

struct DeepLinkRequest {
    var pathComponents: ArraySlice<Substring>
    var queryItem: [String: ArraySlice<Substring?>]
}

extension DeepLinkRequest {
    init(url: URL) {
        
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        
        self.init(
            pathComponents: url.path.split(separator: "/")[...],
            queryItem: queryItems.reduce(into: [:]) { dictionary, item in
                dictionary[item.name, default: []].append(item.value?[...])
            }
        )
    }
}

struct PathComponent: Parser {
    let component: String
    
    init(_ component: String) {
        self.component = component
    }
    
    func parse(_ input: inout DeepLinkRequest) throws -> Void? {
        guard input.pathComponents.first == self.component[...] else {
            return nil
        }
        
        input.pathComponents.removeFirst()
        return ()
    }
}

let deepLinker = AnyParser<URL, Tab> { url in
    switch url.path {
    case "/one":
        return .one
    case "/inventory":
        return .inventory
    case "/three":
        return .three
    default:
        return .none
    }
}

enum Tab: Equatable {
    case one, inventory, three, none
}

final class AppViewModel: ObservableObject {
    @Published var selectedTab: Tab
    
    /**
     You will not get notified of every change inside the InventoryViewModel, but rather you will only be notified when the whole field is replaced all at once.
     **/
    @Published var inventoryViewModel: InventoryViewModel
    
    init(
        selectedTab: Tab,
        inventoryViewModel: InventoryViewModel = .init()
    ) {
        self.selectedTab = selectedTab
        self.inventoryViewModel = inventoryViewModel
    }
    
    func open(url: URL) {
        var url = url
        if let tab = try? deepLinker.parse(&url) {
            self.selectedTab = tab
        }
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
            NavigationView {
                InventoryView(viewModel: self.viewModel.inventoryViewModel)
            }
            .tabItem {
                Text("Inventory")
            }
            .tag(Tab.inventory)
            
            Text("Three")
                .tabItem {
                    Text("Three")
                }
                .tag(Tab.three)
        }
        .tabViewStyle(DefaultTabViewStyle())
        .onOpenURL { url in
            self.viewModel.open(url: url)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppViewModel(selectedTab: .inventory))
            .preferredColorScheme(.dark)
    }
}
