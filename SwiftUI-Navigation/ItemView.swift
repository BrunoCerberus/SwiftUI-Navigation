//
//  ItemView.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 22/11/21.
//

import SwiftUI
import CasePaths

final class ItemViewModel: Identifiable, ObservableObject {
    @Published var item: Item
    @Published var nameIsDuplicate: Bool = false
    
    var id: Item.ID { self.item.id }
    
    init(item: Item) {
        self.item = item
        
        Task { @MainActor in
            // same as sink from publishers, but fancier
            for await item in self.$item.values {
                try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 300)
                self.nameIsDuplicate = item.name == "Keyboard"
            }
        }
    }
}

struct ColorPickerView: View {
    @Binding var color: Item.Color?
    @Environment(\.dismiss) var dismiss
    @State var newColors: [Item.Color] = []
    
    var body: some View {
        Form {
            Button(action: {
                self.color = nil
                self.dismiss()
            }) {
                HStack {
                    Text("None")
                    Spacer()
                    if self.color == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Section(header: Text("Default colors")) {
                ForEach(Item.Color.defaults, id: \.name) { color in
                    Button(action: {
                        self.color = color
                        self.dismiss()
                    }) {
                        HStack {
                            Text(color.name)
                            Spacer()
                            if self.color == color {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            if !self.newColors.isEmpty {
                Section(header: Text("New colors")) {
                    ForEach(self.newColors, id: \.name) { color in
                        Button(action: {
                            self.color = color
                            self.dismiss()
                        }) {
                            HStack {
                                Text(color.name)
                                Spacer()
                                if self.color == color {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            Task { @MainActor in
                try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 500)
                self.newColors = [
                    .init(name: "Pink", red: 1, green: 0.7, blue: 0.7)
                ]
            }
        }
    }
}

struct ItemView: View {
    
    // The problem with @State that it takes initial values but not consider to
    // re-render screen with any changed of its value from outside
//    @Binding var item: Item
    @ObservedObject var viewModel: ItemViewModel
    
    var body: some View {
        VStack {
            Form {
                TextField("Name", text: self.$viewModel.item.name)
                    .background(self.viewModel.nameIsDuplicate ? Color.red.opacity(0.1) : Color.clear)
                
                NavigationLink(destination: ColorPickerView(color: self.$viewModel.item.color)) {
                    HStack {
                        Text("Color")
                        Spacer()
                        if let color = self.viewModel.item.color {
                            Rectangle()
                                .frame(width: 30, height: 30)
                                .foregroundColor(color.swiftUIColor)
                                .border(Color.black, width: 1)
                        }
                        Text(viewModel.item.color?.name ?? "None")
                            .foregroundColor(.gray)
                    }
                }
                
                IfCaseLet(self.$viewModel.item.status, pattern: /Item.Status.inStock) {
                   $quantity in
                    
                    Section(header: Text("In Stock")) {
                        Stepper(
                            "Quantity: \(quantity)",
                            value: $quantity
                        )
                        Button("Mark as sold out") {
                            self.viewModel.item.status = .outOfStock(isOnBackOrder: false)
                        }
                    }
                }
                
                IfCaseLet(self.$viewModel.item.status, pattern: /Item.Status.outOfStock) {
                    $isOnBackOrder in
                    
                    Section(header: Text("Out of Stock")) {
                        Toggle(
                            "Is on back order?",
                            isOn: $isOnBackOrder
                        )
                        Button("Is back in stock!") {
                            self.viewModel.item.status = .inStock(quantity: 1)
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
               viewModel: ItemViewModel(
                item: Item(
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
