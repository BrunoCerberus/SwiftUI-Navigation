//
//  SwiftUI_NavigationApp.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 20/11/21.
//

import SwiftUI

@main
struct SwiftUI_NavigationApp: App {
    
    let appViewModel: AppViewModel = AppViewModel(selectedTab: .inventory)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}
