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
        let viewModel = InventoryViewModel(
            inventory: [
                .init(item: .init(name: "Keyboard", color: .red, status: .inStock(quantity: 1)))
            ]
        )
        
        // When deleteButtonTapped is executed
        viewModel.inventory[0].deleteButtonTapped()
        // route must have an enum value .deleteAlert
        XCTAssertEqual(viewModel.inventory[0].route, .deleteAlert)
        
        // and when deleteConfirmationButtonTapped is executed
        viewModel.inventory[0].deleteConfirmationButtonTapped()
        
        // my inventory array must have nothing
        XCTAssertEqual(viewModel.inventory.count, 0)
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
//        XCTAssertEqual(viewModel.inventory[0].route, .duplicate(item))
        // and then route variable for that particular ItemRowViewModel must be .duplicate(Itm)
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
}
