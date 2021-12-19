//
//  LazyView.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 19/12/21.
//


/*
Example usage:
   struct ContentView: View {
       var body: some View {
           NavigationView {
               NavigationLink(destination: LazyView(Text("My details page")) {
                   Text("Go to details")
               }
           }
       }
   }
*/


import SwiftUI

public struct LazyView<Content: View>: View {
    private let build: () -> Content
    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    public var body: Content {
        build()
    }
}
