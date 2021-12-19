//
//  Inventory.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 20/11/21.
//

import SwiftUI
import IdentifiedCollections

struct Item: Equatable, Identifiable {
  let id = UUID()
  var name: String
  var color: Color?
  var status: Status

  enum Status: Equatable {
    case inStock(quantity: Int)
    case outOfStock(isOnBackOrder: Bool)

    var isInStock: Bool {
      guard case .inStock = self else { return false }
      return true
    }
  }

  struct Color: Equatable, Hashable {
    var name: String
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0

    static var defaults: [Self] = [
      .red,
      .green,
      .blue,
      .black,
      .yellow,
      .white,
    ]

    static let red = Self(name: "Red", red: 1)
    static let green = Self(name: "Green", green: 1)
    static let blue = Self(name: "Blue", blue: 1)
    static let black = Self(name: "Black")
    static let yellow = Self(name: "Yellow", red: 1, green: 1)
    static let white = Self(name: "White", red: 1, green: 1, blue: 1)

    var swiftUIColor: SwiftUI.Color {
        SwiftUI.Color(red: self.red, green: self.green, blue: self.blue)
    }
  }
}

final class InventoryViewModel: ObservableObject {
    @Published var inventory: IdentifiedArrayOf<ItemRowViewModel>
    @Published var itemToAdd: Item?
    
    init(
        inventory: IdentifiedArrayOf<ItemRowViewModel> = [],
        itemToAdd: Item? = nil
    ) {
        self.inventory = []
        self.itemToAdd = itemToAdd
        
        for itemRowViewModel in inventory {
            self.bind(itemRowViewModel: itemRowViewModel)
        }
    }
    
    private func bind(itemRowViewModel: ItemRowViewModel) {
        itemRowViewModel.onDelete = { [weak self, item = itemRowViewModel.item] in
            withAnimation {
                self?.delete(item: item)
            }
        }
        
        itemRowViewModel.onDuplicate = { [weak self] item in
            withAnimation {
                self?.add(item: item)
            }
        }
        self.inventory.append(itemRowViewModel)
    }
    
    func add(item: Item) {
        withAnimation {
            self.bind(itemRowViewModel: ItemRowViewModel(item: item))
            self.itemToAdd = nil
        }
    }
    
    func delete(item: Item) {
        withAnimation {
            _ = inventory.remove(id: item.id)
        }
    }
    
    func addButtonTapped() {
        self.itemToAdd = Item(name: "", color: nil, status: .inStock(quantity: 1))
        
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 500 * NSEC_PER_MSEC)
            self.itemToAdd?.name = "Bluetooth Keyboard"
        }
    }
    
    func dismissSheet() {
        self.itemToAdd = nil
    }
}

struct InventoryView: View {
    @ObservedObject var viewModel: InventoryViewModel
    
    var body: some View {
        List {
            ForEach(
                self.viewModel.inventory,
                content: ItemRowView.init(viewModel:)
            )
                .onDelete(perform: delete)
        }
        .sheet(unwrap: $viewModel.itemToAdd) { $itemToAdd in
            NavigationView {
                ItemView(item: $itemToAdd)
                    .navigationTitle("Add")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", action: viewModel.dismissSheet)
                        }
                        
                        ToolbarItem(placement: .primaryAction) {
                            Button("Save") {
                                viewModel.add(item: itemToAdd)
                            }
                        }
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", action: self.viewModel.addButtonTapped)
            }
        }
        .navigationTitle("Inventory")
    }
    
    private func delete(offsets: IndexSet) {
        for index in offsets {
            let rowViewModel: ItemRowViewModel = viewModel.inventory[index]
            viewModel.delete(item: rowViewModel.item)
        }
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        
        let _ = Item(name: "Keyboard", color: .blue, status: .inStock(quantity: 100))
        NavigationView {
            InventoryView(
                viewModel: InventoryViewModel(
                    inventory: [
                        ItemRowViewModel(item: Item(name: "Charger", color: .yellow, status: .inStock(quantity: 20))),
                        ItemRowViewModel(item: Item(name: "Phone", color: .green, status: .outOfStock(isOnBackOrder: true))),
                        ItemRowViewModel(item: Item(name: "Headphones", color: .green, status: .outOfStock(isOnBackOrder: false))),
                    ]
                )
            )
        }
        .preferredColorScheme(.dark)
    }
}
