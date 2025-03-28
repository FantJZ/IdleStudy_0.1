//
//  FishLibraryBackpackView.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/27.
//

import SwiftUI

struct FishLibraryBackpackView: View {
    @ObservedObject var manager = PlayerBackpackManager.shared
    @Binding var selectedFish: FishInFishBusket?

    var body: some View {
        BackpackGridView(
            title: "鱼库",
            items: manager.fishLibraryItems,
            columns: manager.fishLibraryCols,
            maxRows: manager.fishLibraryRows,
            showTotalValue: false,
            showSellAll: false,
            showSort: false,
            totalValue: 0,
            onSellAll: nil,
            onSort: nil,
            onTapItem: { fish in selectedFish = fish },
            imageProvider: { fish in
                if let uiImage = UIImage(named: fish.image) {
                    return Image(uiImage: uiImage)
                } else {
                    return Image(systemName: "fish")
                }
            }
        )
    }
}
