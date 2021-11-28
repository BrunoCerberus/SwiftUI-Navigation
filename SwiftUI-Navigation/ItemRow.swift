//
//  ItemRow.swift
//  SwiftUI-Navigation
//
//  Created by bruno on 28/11/21.
//

import SwiftUI

final class ItemRowViewModel: Identifiable, ObservableObject {
    @Published var item: Item
    @Published var deleteItemAlertIsPresented: Bool
    
    var onDelete: () -> Void = {}
    
    var id: Item.ID { self.item.id }
    
    init(
        item: Item,
        deleteItemAlertIsPresented: Bool = false
    ) {
        self.item = item
        self.deleteItemAlertIsPresented = deleteItemAlertIsPresented
    }
    
    func deleteButtonTapped() {
        self.deleteItemAlertIsPresented = true
    }
    
    func deleteConfirmationButtonTapped() {
        deleteItemAlertIsPresented = false
        onDelete()
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
            
            Button(action: viewModel.deleteButtonTapped) {
                Image(systemName: "trash.fill")
            }
            .padding(.leading)
        }
        .confirmationDialog(
            self.viewModel.item.name,
            isPresented: self.$viewModel.deleteItemAlertIsPresented,
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
        .onTapGesture {
//            self.viewModel.itemToAdd = item
        }
        .buttonStyle(.plain)
        .foregroundColor(viewModel.item.status.isInStock ? nil : .gray)
    }
}
