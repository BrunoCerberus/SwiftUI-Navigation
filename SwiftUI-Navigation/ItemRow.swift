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
    
    enum Route: Equatable {
        case deleteAlert
        case duplicate(ItemViewModel)
        case edit(ItemViewModel)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.deleteAlert, .deleteAlert):
                return false
            case let (.duplicate(lhs), .duplicate(rhs)):
                return lhs === rhs
            case let (.edit(lhs), .edit(rhs)):
                return lhs === rhs
            case (.deleteAlert, _), (.duplicate, _), (.edit, _):
                return false
            }
        }
    }
    
    var onDelete: () -> Void = {}
    var onDuplicate: (Item) -> Void = { _ in }
    
    var id: Item.ID { self.item.id }
    
    init(item: Item) {
        self.item = item
    }
    
    func deleteButtonTapped() {
        self.route = .deleteAlert
    }
    
    func deleteConfirmationButtonTapped() {
        self.route = nil
        onDelete()
    }
    
    func setEditNavigation(isActive: Bool) {
        self.route = isActive ? .edit(.init(item: self.item)) : nil
    }
    
    @Published var isSaving = false
    
    func edit(item: Item) {
        self.isSaving = true
        Task { @MainActor in
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            self.isSaving = false
            self.item = item
            self.route = nil
        }
    }
    
    func cancelButtonTapped() {
        self.route = nil
    }
    
    func duplicateButtonTapped() {
        self.route = .duplicate(.init(item: self.item.duplicate()))
    }
    
    func duplicate(item: Item) {
        self.onDuplicate(item)
        self.route = nil
    }
}

struct ItemRowView: View {
    @ObservedObject var viewModel: ItemRowViewModel
    
    var body: some View {
        // here we can add the whole view into NavigationLink, this turn the whole tappable view into a link
        NavigationLink(
            unwrap: self.$viewModel.route,
            case: /ItemRowViewModel.Route.edit,
            onNavigate: self.viewModel.setEditNavigation,
            destination: { $itemViewModel in
                ItemView(viewModel: itemViewModel)
                    .navigationTitle("Edit")
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", action: viewModel.cancelButtonTapped)
                        }
                        
                        ToolbarItem(placement: .primaryAction) {
                            HStack {
                                if self.viewModel.isSaving {
                                    ProgressView()
                                }
                                Button("Save") {
                                    self.viewModel.edit(item: itemViewModel.item)
                                }
                            }
                            .disabled(self.viewModel.isSaving)
                        }
                    }
            }
        ) {
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
                
                Button(action: viewModel.duplicateButtonTapped) {
                    Image(systemName: "square.fill.on.square.fill")
                }
                .padding(.leading)
                
                Button(action: viewModel.deleteButtonTapped) {
                    Image(systemName: "trash.fill")
                }
                .padding(.leading)
            }
            .confirmationDialog(
                title: { Text(self.viewModel.item.name) },
                titleVisibility: .visible,
                unwrap: self.$viewModel.route,
                case: /ItemRowViewModel.Route.deleteAlert,
                actions: {
                    Button("Delete", role: .destructive) {
                        self.viewModel.deleteConfirmationButtonTapped()
                    }
                },
                message: {
                    Text("Are you sure that you want to delete this item?")
                }
            )
            .popover(
                unwrap: self.$viewModel.route,
                case: /ItemRowViewModel.Route.duplicate
            ) { $itemViewModel in
                NavigationView {
                    ItemView(viewModel: itemViewModel)
                        .navigationTitle("Duplicate")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel", action: viewModel.cancelButtonTapped)
                            }
                            
                            ToolbarItem(placement: .primaryAction) {
                                Button("Add") {
                                    self.viewModel.duplicate(item: itemViewModel.item)
                                }
                            }
                        }
                }
                .frame(minWidth: 300, minHeight: 500)
            }
            .buttonStyle(.plain)
            .foregroundColor(viewModel.item.status.isInStock ? nil : .gray)
        }
    }
}
