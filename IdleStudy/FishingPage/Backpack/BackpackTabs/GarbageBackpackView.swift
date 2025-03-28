//
//  GarbageBackpackView.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/27.
//

import SwiftUI

struct GarbageBackpackView: View {
    @ObservedObject var manager = PlayerBackpackManager.shared
    @Binding var selectedGarbage: BackpackGarbageItem?

    var body: some View {
        BackpackGridView(
            title: "垃圾",
            items: manager.garbageItems,
            columns: manager.garbageCols,
            maxRows: manager.garbageRows,
            showTotalValue: true,
            showSellAll: true,
            showSort: true,
            totalValue: manager.totalGarbageValue(),
            onSellAll: { manager.sellAllGarbage() },
            onSort: { manager.sortGarbage(by: .price) }, // 可改为弹出菜单
            onTapItem: { item in selectedGarbage = item },
            imageProvider: { item in
                item.image.isEmpty ? Image(systemName: "trash") : Image(item.image)
            }
        )
    }
}
