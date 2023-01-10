//
//  ContentView.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 20/11/21.
//

import URLRouting
import SwiftUI

enum AppRoute {
  case one
  case inventory
  case three
}


let appRouter = OneOf {
  // GET /books
  Route(.case(AppRoute.one)) {
    Path { "one" }
  }

  // GET /books/:id
  Route(.case(AppRoute.inventory)) {
    Path { "inventory" }
  }

  // GET /books/search?query=:query&count=:count
  Route(.case(AppRoute.three)) {
    Path { "three" }
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
    
    func handleDeepLink(url: URL) {
      switch try? appRouter.match(url: url) {
      case .one:
          self.selectedTab = .one

      case .inventory:
          self.selectedTab = .inventory

      case .three:
          self.selectedTab = .three
      case .none:
          break
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
            self.viewModel.handleDeepLink(url: url)
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
