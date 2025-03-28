//
//  TreasureBackpackView.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/27.
//

import SwiftUI

struct TreasureBackpackView: View {
    @ObservedObject var manager = PlayerBackpackManager.shared
    @Binding var selectedTreasure: BackpackTreasureItem?

    var body: some View {
        BackpackGridView(
            title: "宝藏",
            items: manager.treasureItems,
            columns: manager.treasureCols,
            maxRows: manager.treasureRows,
            showTotalValue: true,
            showSellAll: true,
            showSort: true,
            totalValue: manager.totalTreasureValue(),
            onSellAll: { manager.sellAllTreasure() },
            onSort: { manager.sortTreasure(by: .rarity) },
            onTapItem: { item in selectedTreasure = item },
            imageProvider: { _ in Image(systemName: "star") }
        )
    }
}
