//
//  ItemView.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 22/11/21.
//

import SwiftUI

struct ItemView: View {
    var body: some View {
        Form {
            TextField("Name", text: .constant(""))
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView()
    }
}
