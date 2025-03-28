//
//  BackpackGridView.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/27.
//

import SwiftUI

struct BackpackGridView<Item: Identifiable>: View {
    let title: String
    let items: [Item]
    let columns: Int
    let maxRows: Int? // nil 表示无限行

    // 显示控制项
    let showTotalValue: Bool
    let showSellAll: Bool
    let showSort: Bool

    let totalValue: Int
    let onSellAll: (() -> Void)?
    let onSort: (() -> Void)?
    let onTapItem: (Item) -> Void
    let imageProvider: (Item) -> Image

    var body: some View {
        VStack {
            // 顶部控制栏
            if showTotalValue || showSellAll || showSort {
                HStack {
                    if showTotalValue {
                        Text("总价值: \(totalValue)")
                    }
                    Spacer()
                    if showSellAll, let onSellAll {
                        Button("售卖全部") {
                            onSellAll()
                        }
                    }
                    if showSort, let onSort {
                        Button("排序") {
                            onSort()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            // 网格展示
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: columns),
                    spacing: 10
                ) {
                    ForEach(gridItems, id: \.id) { item in
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(1, contentMode: .fit)

                            imageProvider(item)
                                .resizable()
                                .scaledToFit()
                                .padding(12)
                        }
                        .onTapGesture {
                            onTapItem(item)
                        }
                    }

                    if let emptyCount = emptySlotsCount {
                        ForEach(0..<emptyCount, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.white)
    }

    private var gridItems: [Item] {
        if let maxRows {
            let maxCount = maxRows * columns
            return Array(items.prefix(maxCount))
        } else {
            return items
        }
    }

    private var emptySlotsCount: Int? {
        if let maxRows {
            let total = maxRows * columns
            return max(0, total - items.count)
        }
        return nil
    }
}
