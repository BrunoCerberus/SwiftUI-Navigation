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
        XCTAssertNotNil(viewModel.itemToAdd)
        
        let itemToAdd = try XCTUnwrap(viewModel.itemToAdd)
        
        // When an Item isso added throw .add(item:)
        viewModel.add(item: itemToAdd)
        
        // It must be nothing in itemToAdd
        XCTAssertNil(viewModel.itemToAdd)
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
        let item: Item = .init(name: "Keyboard", color: .red, status: .inStock(quantity: 1))
        let viewModel = InventoryViewModel(
            inventory: [
                .init(item: item)
            ]
        )
        
        viewModel.inventory[0].duplicateButtonTapped()
//        XCTAssertEqual(viewModel.inventory[0].route, .duplicate(item))
        XCTAssertNotNil(
            (/ItemRowViewModel.Route.duplicate).extract(from: try XCTUnwrap(viewModel.inventory[0].route))
        )
        
        let dup = item.duplicate()
        viewModel.inventory[0].duplicate(item: dup)
        
        XCTAssertEqual(viewModel.inventory.count, 2)
        XCTAssertEqual(viewModel.inventory[0].item, item)
        XCTAssertEqual(viewModel.inventory[1].item, dup)
        XCTAssertNil(viewModel.inventory[0].route)
    }
}
