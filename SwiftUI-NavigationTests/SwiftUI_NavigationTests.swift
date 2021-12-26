//
//  SwiftUI_NavigationTests.swift
//  SwiftUI-NavigationTests
//
//  Created by bruno on 10/12/21.
//

import XCTest
import CasePaths
@testable import SwiftUI_Navigation

final class SwiftUI_NavigationTests: XCTestCase {
    func testAddItem() throws {
        let viewModel = InventoryViewModel()
        
        // When addButtonTapped is executed
        viewModel.addButtonTapped()
        
        // There must be an Item in itemToAdd
        XCTAssertNotNil(viewModel.route)
        
        // unwrap an optional into a honest value
        let itemToAdd = try XCTUnwrap((/InventoryViewModel.Route.add).extract(from: try XCTUnwrap(viewModel.route)))
        
        // When an Item is added through .add(item:)
        viewModel.add(item: itemToAdd)
        
        // It must be nothing in itemToAdd
        XCTAssertNil(viewModel.route)
        // The inventonry count must be one
        XCTAssertEqual(viewModel.inventory.count, 1)
        // and the inventory item must be equal to itemToAdd constant
        XCTAssertEqual(viewModel.inventory[0].item, itemToAdd)
    }
    
    func testDeleteItem() {
        // we have an inventory with one item
        let viewModel = InventoryViewModel(
            inventory: [
                .init(item: .init(name: "Keyboard", color: .red, status: .inStock(quantity: 1)))
            ]
        )
        
        // When deleteButtonTapped is executed
        viewModel.inventory[0].deleteButtonTapped()
        // route must have an enum value .deleteAlert
        XCTAssertEqual(viewModel.inventory[0].route, .deleteAlert)
        // and parent must have same enum value
        XCTAssertEqual(viewModel.route, .row(id: viewModel.inventory[0].id, route: .deleteAlert))
        
        
        // and when deleteConfirmationButtonTapped is executed
        viewModel.inventory[0].deleteConfirmationButtonTapped()
        
        // my inventory array must have nothing
        XCTAssertEqual(viewModel.inventory.count, 0)
        // and parent rounte must be nil
        XCTAssertEqual(viewModel.route, nil)
    }
    
    func testDuplicateItem() {
        // There is an Item
        let item: Item = .init(name: "Keyboard", color: .red, status: .inStock(quantity: 1))
        // And a viewModel with this item
        let viewModel = InventoryViewModel(
            inventory: [
                .init(item: item)
            ]
        )
        
        // then user hits on duplicate button
        viewModel.inventory[0].duplicateButtonTapped()
        
        // and then route variable for that particular ItemRowViewModel must be .duplicate(Item)
        XCTAssertNotNil(
            (/ItemRowViewModel.Route.duplicate).extract(from: try XCTUnwrap(viewModel.inventory[0].route))
        )
        
        // now i have a duplicated item called dup that comes from our previous item
        let dup = item.duplicate()
        // and user hits on duplicate button
        viewModel.inventory[0].duplicate(item: dup)
        
        // and now we have two inventories
        XCTAssertEqual(viewModel.inventory.count, 2)
        // and first item is our previous Item
        XCTAssertEqual(viewModel.inventory[0].item, item)
        // and second item is our duplicated item dub
        XCTAssertEqual(viewModel.inventory[1].item, dup)
        // and our route for first item doesn't exists anymore
        XCTAssertNil(viewModel.inventory[0].route)
    }
    
    func testEdit() async throws {
        // There is an Item
        let item: Item = .init(name: "Keyboard", color: .red, status: .inStock(quantity: 1))
        // And a viewModel with this item
        let viewModel = InventoryViewModel(
            inventory: [
                .init(item: item)
            ]
        )
        
        // make navigation with .edit(item:)
        viewModel.inventory[0].setEditNavigation(isActive: true)
        
        // and then route variable for that particular ItemRowViewModel must be .edit(Item)
        XCTAssertNotNil(
            (/ItemRowViewModel.Route.edit).extract(from: try XCTUnwrap(viewModel.inventory[0].route))
        )
        
        // and we make some changes on that item
        var editedItem = item
        editedItem.color = .blue
        
        // hit edit action to save edited item
        viewModel.inventory[0].edit(item: editedItem)
        
        
        // ProgressView must be shown
        XCTAssertEqual(viewModel.inventory[0].isSaving, true)
        
        // wait our async task to be finished
        try await Task.sleep(nanoseconds: NSEC_PER_SEC + 100 * NSEC_PER_MSEC)
        
        // row route must be nil
        XCTAssertNil(viewModel.inventory[0].route)
        // parent route must be nil
        XCTAssertNil(viewModel.route)
        // our row item must be the editedItem
        XCTAssertEqual(viewModel.inventory[0].item, editedItem)
        // and ProgressView must hide
        XCTAssertEqual(viewModel.inventory[0].isSaving, false)
    }
}
