import SwiftUI

struct PlayerBackpackView: View {
    @ObservedObject var manager = PlayerBackpackManager.shared

    @State private var selectedGarbage: BackpackGarbageItem?
    @State private var selectedTreasure: BackpackTreasureItem?
    @State private var selectedFishBusket: FishInFishBusket?
    @State private var selectedFishLibrary: FishInFishBusket?

    @Binding var showPlayerBackpack: Bool

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack {
                    Button("关闭") {
                        showPlayerBackpack.toggle()
                    }

                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(PlayerBackpackManager.BackpackTab.allCases, id: \.self) { tab in
                                Button(action: {
                                    manager.selectedTab = tab
                                }) {
                                    Text(tab.rawValue)
                                        .font(.headline)
                                        .foregroundColor(manager.selectedTab == tab ? .blue : .primary)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.gray.opacity(manager.selectedTab == tab ? 0.3 : 0.2))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: 50)
                }
                .background(Color.white)

                contentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.top, 40)

            // 弹出详情视图
            .sheet(item: $selectedGarbage) { item in
                GarbageDetailView(item: item)
            }
            .sheet(item: $selectedTreasure) { item in
                TreasureDetailView(item: item)
            }
            .sheet(item: $selectedFishBusket) { fish in
                FishBusketDetailView(fish: fish, manager: manager)
            }
            .sheet(item: $selectedFishLibrary) { fish in
                FishLibraryDetailView(fish: fish)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch manager.selectedTab {
        case .equipment:
            Text("这里是装备页面（暂未启用网格）")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)

        case .garbage:
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
                onSort: { manager.sortGarbage(by: .price) }, // 你也可以换成 Menu 控件
                onTapItem: { selectedGarbage = $0 },
                imageProvider: { item in
                    item.image.isEmpty ? Image(systemName: "trash") : Image(item.image)
                }
            )

        case .treasure:
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
                onTapItem: { selectedTreasure = $0 },
                imageProvider: { _ in Image(systemName: "star") }
            )

        case .fishbusket:
            BackpackGridView(
                title: "鱼篓",
                items: manager.fishBusketItems,
                columns: manager.fishBusketCols,
                maxRows: nil,
                showTotalValue: true,
                showSellAll: true,
                showSort: false,
                totalValue: manager.totalFishBusketValue(),
                onSellAll: { manager.sellAllFishBusket() },
                onSort: nil,
                onTapItem: { selectedFishBusket = $0 },
                imageProvider: { fish in
                    if let uiImage = UIImage(named: fish.image) {
                        return Image(uiImage: uiImage)
                    } else {
                        return Image(systemName: "fish")
                    }
                }
            )

        case .fishlibrary:
            BackpackGridView(
                title: "鱼库",
                items: manager.fishLibraryItems,
                columns: manager.fishLibraryCols,
                maxRows: manager.fishLibraryRows,
                showTotalValue: true,
                showSellAll: false,
                showSort: false,
                totalValue: 0,
                onSellAll: nil,
                onSort: nil,
                onTapItem: { selectedFishLibrary = $0 },
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
}

#Preview{
    PlayerBackpackView(showPlayerBackpack: .constant(true))
}
