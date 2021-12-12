//
//  SwiftUI_NavigationTests.swift
//  SwiftUI-NavigationTests
//
//  Created by bruno on 10/12/21.
//

import XCTest
@testable import SwiftUI_Navigation

final class SwiftUI_NavigationTests: XCTestCase {
    func testAddItem() throws {
        let viewModel = InventoryViewModel()
        viewModel.addButtonTapped()
        
        XCTAssertNotNil(viewModel.itemToAdd)
        
        let itemToAdd = try XCTUnwrap(viewModel.itemToAdd)
        
        viewModel.add(item: itemToAdd)
        
        XCTAssertNil(viewModel.itemToAdd)
        XCTAssertEqual(viewModel.inventory.count, 1)
        XCTAssertEqual(viewModel.inventory[0].item, itemToAdd)
    }
    
    func testDeleteItem() {
        let viewModel = InventoryViewModel(
            inventory: [
                .init(item: .init(name: "Keyboard", color: .red, status: .inStock(quantity: 1)))
            ]
        )
        
        viewModel.inventory[0].deleteButtonTapped()
        
        XCTAssertEqual(viewModel.inventory[0].route, .deleteAlert)
        
        viewModel.inventory[0].deleteConfirmationButtonTapped()
        
        XCTAssertEqual(viewModel.inventory.count, 0)
    }
}
