//
//  SwiftUI_NavigationApp.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 20/11/21.
//

import SwiftUI

@main
struct SwiftUI_NavigationApp: App {
    
    let keyboard = Item(name: "Keyboard", color: .blue, status: .inStock(quantity: 100))
    
    var body: some Scene {
        let appViewModel: AppViewModel = AppViewModel(
            selectedTab: .inventory,
            inventoryViewModel: InventoryViewModel(
                inventory: [
                    Item(name: "Charger", color: .yellow, status: .inStock(quantity: 20)),
                    Item(name: "Phone", color: .green, status: .outOfStock(isOnBackOrder: true)),
                    Item(name: "Headphones", color: .green, status: .outOfStock(isOnBackOrder: false)),
                ],
                itemToAdd: nil,
                itemToDelete: nil
            )
        )
        
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
