//
//  SwiftUI_NavigationApp.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 20/11/21.
//

import SwiftUI

@main
struct SwiftUI_NavigationApp: App {
    
    let keyboard: Item = Item(name: "Keyboard", color: .blue, status: .inStock(quantity: 100))
    
    var body: some Scene {
        let appViewModel: AppViewModel = AppViewModel(
            selectedTab: .one,
            inventoryViewModel: InventoryViewModel(
                inventory: [
                    .init(item: keyboard),
                    .init(item: Item(name: "Charger", color: .yellow, status: .inStock(quantity: 20))),
                    .init(item: Item(name: "Phone", color: .green, status: .outOfStock(isOnBackOrder: true))),
                    .init(item: Item(name: "Headphones", color: .green, status: .outOfStock(isOnBackOrder: false))),
                ],
                route: nil
                // deeplink samples
//                route: .row(id: keyboard.id, route: .deleteAlert)
                
//                route: .row(
//                    id: keyboard.id,
//                    route: .edit(.init(
//                        item: keyboard,
//                        route: .colorPicker
//                    ))
//                )
            )
        )
        
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
