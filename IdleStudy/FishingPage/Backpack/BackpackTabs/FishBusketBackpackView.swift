//
//  FishBusketBackpackView.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/27.
//

import SwiftUI

struct FishBusketBackpackView: View {
    @ObservedObject var manager = PlayerBackpackManager.shared
    @Binding var selectedFish: FishInFishBusket?

    var body: some View {
        BackpackGridView(
            title: "鱼篓",
            items: manager.fishBusketItems,
            columns: manager.fishBusketCols,
            maxRows: nil, // 无限行
            showTotalValue: true,
            showSellAll: true,
            showSort: false,
            totalValue: manager.totalFishBusketValue(),
            onSellAll: { manager.sellAllFishBusket() },
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
