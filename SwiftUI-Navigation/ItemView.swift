//
//  ItemView.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 22/11/21.
//

import SwiftUI
import CasePaths

struct ItemView: View {
    
    // The problem with @State that it takes initial values but not consider to
    // re-render screen with any changed of its value from outside
//    @State var item: Item = Item(
//        name: "",
//        color: nil,
//        status: .inStock(quantity: 1)
//    )
    @Binding var item: Item
    
    var body: some View {
        VStack {
            Form {
                TextField("Name", text: self.$item.name)
                Picker(selection: self.$item.color, label: Text("Color")) {
                    Text("None")
                        .tag(Item.Color?.none)
                    
                    ForEach(Item.Color.defaults, id: \.name) { color in
                        Text(color.name)
                            .tag(Optional(color))
                    }
                }
                
                IfCaseLet(self.$item.status, pattern: /Item.Status.inStock) {
                   $quantity in
                    
                    Section(header: Text("In Stock")) {
                        Stepper(
                            "Quantity: \(quantity)",
                            value: $quantity
                        )
                        Button("Mark as sold out") {
                            self.item.status = .outOfStock(isOnBackOrder: false)
                        }
                    }
                }
                
                IfCaseLet(self.$item.status, pattern: /Item.Status.outOfStock) {
                    $isOnBackOrder in
                    
                    Section(header: Text("Out of Stock")) {
                        Toggle(
                            "Is on back order?",
                            isOn: $isOnBackOrder
                        )
                        Button("Is back in stock!") {
                            self.item.status = .inStock(quantity: 1)
                        }
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItemView(
                item: .constant(
                    Item(
                        name: "",
                        color: nil,
                        status: .inStock(quantity: 1)
                    )
                )
            )
        }
        .preferredColorScheme(.dark)
    }
}
