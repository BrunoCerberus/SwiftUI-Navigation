//
//  ItemRow.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 28/11/21.
//

import SwiftUI
import CasePaths

final class ItemRowViewModel: Identifiable, ObservableObject {
    @Published var item: Item
    @Published var route: Route?
    
    enum Route {
        case deleteAlert
        case duplicate(Item)
        case edit(Item)
    }
    
    var onDelete: () -> Void = {}
    
    var id: Item.ID { self.item.id }
    
    init(
        item: Item,
        route: Route? = nil
    ) {
        self.item = item
        self.route = route
    }
    
    func deleteButtonTapped() {
        self.route = .deleteAlert
    }
    
    func deleteConfirmationButtonTapped() {
        self.route = nil
        onDelete()
    }
    
    func editButtonTapped() {
        self.route = .edit(self.item)
    }
    
    func edit(item: Item) {
        self.item = item
        self.route = nil
    }
    
    func cancelButtonTapped() {
        self.route = nil
    }
}

struct ItemRowView: View {
    @ObservedObject var viewModel: ItemRowViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.item.name)
                
                switch viewModel.item.status {
                case let .inStock(quantity):
                    Text("In stock: \(quantity)")
                case let .outOfStock(isOnBackOrder):
                    Text("Out of stock" + (isOnBackOrder ? "on back order" : ""))
                }
            }
            
            Spacer()
            
            if let color = viewModel.item.color {
                Rectangle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(color.swiftUIColor)
                    .border(Color.black, width: 1)
            }
            
            Button(action: viewModel.editButtonTapped) {
                Image(systemName: "pencil")
            }
            .padding(.leading)
            
            Button(action: viewModel.deleteButtonTapped) {
                Image(systemName: "trash.fill")
            }
            .padding(.leading)
        }
        .confirmationDialog(
            self.viewModel.item.name,
            isPresented: self.$viewModel.route.isPresent(/ItemRowViewModel.Route.deleteAlert),
            titleVisibility: .visible,
            actions: {
                Button("Delete", role: .destructive) {
                    self.viewModel.deleteConfirmationButtonTapped()
                }
            },
            message: {
                Text("Are you sure that you want to delete this item?")
            }
        )
        .sheet(
            unwrap: Binding(
                get: { guard case let .some(.edit(item)) = self.viewModel.route else { return nil }
                    return item
                },
                set: { item in
                    if let item = item {
                        self.viewModel.route = .edit(item)
                    }
                }
            )
        ) { $item in
            NavigationView {
                ItemView(item: $item)
                    .navigationTitle("Edit")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", action: viewModel.cancelButtonTapped)
                        }
                        
                        ToolbarItem(placement: .primaryAction) {
                            Button("Save") {
                                self.viewModel.edit(item: item)
                            }
                        }
                    }
            }
        }
        .buttonStyle(.plain)
        .foregroundColor(viewModel.item.status.isInStock ? nil : .gray)
    }
}
