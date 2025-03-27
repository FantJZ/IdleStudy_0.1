import SwiftUI

/// 主背包视图，包含左侧垂直 Tab 选择，以及垃圾/宝藏/装备/鱼篓/鱼库 的具体界面
struct PlayerBackpackView: View {
    @ObservedObject var manager = PlayerBackpackManager.shared
    // 用于弹出详情的垃圾 & 宝藏
    @State private var selectedGarbage: BackpackGarbageItem?
    @State private var selectedTreasure: BackpackTreasureItem?
    
    // 用于弹出详情的鱼篓 & 鱼库
    @State private var selectedFishBusket: FishInFishBusket?
    @State private var selectedFishLibrary: FishInFishBusket?
    
    @Binding var showPlayerBackpack: Bool
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack {
                    Button(
                        action: {
                            showPlayerBackpack.toggle()
                        },
                        label: {
                            Text("关闭")
                        }
                    )
                    // 左侧可滚动 Tab 栏
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
                                        .background(
                                            Color.gray.opacity(manager.selectedTab == tab ? 0.3 : 0.2)
                                        )
                                }
                            }
                        }
                    }
                    .frame(maxWidth: 50)
                }
                .background(Color.white)
                
                // 右侧内容视图
                contentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.top, 40)
            // 弹出详情：垃圾、宝藏、鱼篓、鱼库
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
    
    /// 根据 selectedTab 切换相应内容视图
    @ViewBuilder
    private var contentView: some View {
        switch manager.selectedTab {
        case .equipment:
            equipmentView
        case .garbage:
            garbageView
        case .treasure:
            treasureView
        case .fishbusket:
            fishBusketView
        case .fishlibrary:
            fishLibraryView
        }
    }
}

// MARK: - 各 Tab 内容

extension PlayerBackpackView {
    
    // 装备（保留空）
    private var equipmentView: some View {
        Text("这里是装备 Tab（暂时为空）")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
    }
    
    // MARK: - 垃圾
    private var garbageView: some View {
        VStack {
            // 顶部：总价值 & 售卖 & 排序
            HStack {
                Text("总价值: \(manager.totalGarbageValue())")
                Spacer()
                Button("售卖全部") {
                    manager.sellAllGarbage()
                }
                Menu("排序") {
                    Button("名称") {
                        manager.sortGarbage(by: .name)
                    }
                    Button("价格") {
                        manager.sortGarbage(by: .price)
                    }
                    Button("数量") {
                        manager.sortGarbage(by: .quantity)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // 网格，只显示一个占位图标，点击后弹出详情
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: manager.garbageCols),
                    spacing: 10
                ) {
                    ForEach(0 ..< manager.garbageRows * manager.garbageCols, id: \.self) { index in
                        if index < manager.garbageItems.count {
                            let item = manager.garbageItems[index]
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .aspectRatio(1, contentMode: .fit)
                                
                                // 占位图标（因为 BackpackGarbageItem 没有 image 字段）
                                if !item.image.isEmpty {
                                    Image(item.image) // 假设 item.image 对应 Asset Catalog 中的图片名
                                        .resizable()
                                        .scaledToFit()
                                        .padding(12)
                                } else {
                                    Image(systemName: "trash")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(12)
                                        .foregroundColor(.black)
                                }
                            }
                            .onTapGesture {
                                // 点击后弹出垃圾详情
                                selectedGarbage = item
                            }
                        } else {
                            // 空位
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
    
    // MARK: - 宝藏
    private var treasureView: some View {
        VStack {
            // 顶部：总价值 & 售卖 & 排序
            HStack {
                Text("总价值: \(manager.totalTreasureValue())")
                Spacer()
                Button("售卖全部") {
                    manager.sellAllTreasure()
                }
                Menu("排序") {
                    Button("名称") {
                        manager.sortTreasure(by: .name)
                    }
                    Button("价格") {
                        manager.sortTreasure(by: .price)
                    }
                    Button("稀有度") {
                        manager.sortTreasure(by: .rarity)
                    }
                    Button("数量") {
                        manager.sortTreasure(by: .quantity)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // 网格，只显示一个占位图标
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: manager.treasureCols),
                    spacing: 10
                ) {
                    ForEach(0 ..< manager.treasureRows * manager.treasureCols, id: \.self) { index in
                        if index < manager.treasureItems.count {
                            let item = manager.treasureItems[index]
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .aspectRatio(1, contentMode: .fit)
                                
                                // 占位图标
                                Image(systemName: "star")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .foregroundColor(.black)
                            }
                            .onTapGesture {
                                selectedTreasure = item
                            }
                        } else {
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
    
    // MARK: - 鱼篓（fishbusket）
    private var fishBusketView: some View {
        VStack {
            // 顶部：显示总价值、售卖全部
            HStack {
                Text("总价值: \(manager.totalFishBusketValue())")
                Spacer()
                Button("售卖全部") {
                    manager.sellAllFishBusket()
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // 4 列，不限制行数
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: manager.fishBusketCols),
                    spacing: 10
                ) {
                    ForEach(manager.fishBusketItems) { fish in
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(1, contentMode: .fit)
                            
                            // 如果有 fish.image 可加载对应图片；否则用占位图
                            if let uiImage = UIImage(named: fish.image) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                            } else {
                                Image(systemName: "fish")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .foregroundColor(.blue)
                            }
                        }
                        .onTapGesture {
                            // 点击后弹出鱼篓详情
                            selectedFishBusket = fish
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.white)
    }
    
    // MARK: - 鱼库（fishlibrary）
    private var fishLibraryView: some View {
        VStack {
            HStack {
                Text("鱼库")
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // 4 列 3 行，超出可滚动
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: manager.fishLibraryCols),
                    spacing: 10
                ) {
                    ForEach(0 ..< manager.fishLibraryRows * manager.fishLibraryCols, id: \.self) { index in
                        if index < manager.fishLibraryItems.count {
                            let fish = manager.fishLibraryItems[index]
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .aspectRatio(1, contentMode: .fit)
                                
                                if let uiImage = UIImage(named: fish.image) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .padding(12)
                                } else {
                                    Image(systemName: "fish")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(12)
                                        .foregroundColor(.blue)
                                }
                            }
                            .onTapGesture {
                                selectedFishLibrary = fish
                            }
                        } else {
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
}

// MARK: - 详情视图：鱼篓
struct FishBusketDetailView: View {
    let fish: FishInFishBusket
    @ObservedObject var manager: PlayerBackpackManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("鱼篓详情")
                .font(.title)
            
            // 显示图片
            if let uiImage = UIImage(named: fish.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            } else {
                Image(systemName: "fish")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
            }
            
            // 详细信息
            Text("名称：\(fish.name)")
            Text("品质：\(fish.quality)")
            Text("重量：\(String(format: "%.2f kg", fish.weight))")
            Text("价格：\(fish.price)")
            Text("稀有度：\(fish.rarity)")
            Text("经验：\(fish.exp)")
            
            Button("移到鱼库") {
                manager.moveFishToLibrary(fish)
            }
            
            Button("关闭") {
                // sheet 自动关闭
            }
        }
        .padding()
    }
}

// MARK: - 详情视图：鱼库
struct FishLibraryDetailView: View {
    let fish: FishInFishBusket
    
    var body: some View {
        VStack(spacing: 16) {
            Text("鱼库详情")
                .font(.title)
            
            if let uiImage = UIImage(named: fish.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            } else {
                Image(systemName: "fish")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
            }
            
            Text("名称：\(fish.name)")
            Text("品质：\(fish.quality)")
            Text("重量：\(String(format: "%.2f kg", fish.weight))")
            Text("价格：\(fish.price)")
            Text("稀有度：\(fish.rarity)")
            Text("经验：\(fish.exp)")
            
            Button("关闭") {
                // sheet 自动关闭
            }
        }
        .padding()
    }
}

// MARK: - 垃圾详情视图
struct GarbageDetailView: View {
    let item: BackpackGarbageItem
    
    var body: some View {
        VStack(spacing: 20) {
            Text("垃圾详情")
                .font(.title)
            
            // 这里同样可以放图片，但 BackpackGarbageItem 没有 image 字段
            // 如果想添加，可自行扩展
            Image(item.image)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.black)
            
            Text("名称：\(item.name)")
                .font(.headline)
            Text("价格：\(item.price)")
            Text("池塘：\(item.pond)")
            Text("描述：\(item.description)")
            Text("总数：\(item.totalCount)")
            Text("钓到的总数：\(item.fishedCount)")
            
            Button("关闭") {
                // sheet 自动关闭
            }
        }
        .padding()
    }
}

// MARK: - 宝藏详情视图
struct TreasureDetailView: View {
    let item: BackpackTreasureItem
    
    var body: some View {
        VStack(spacing: 20) {
            Text("宝藏详情")
                .font(.title)
            
            // 同样可放置图片
            Image(systemName: "star")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.black)
            
            Text("名称：\(item.name)")
                .font(.headline)
            Text("价格：\(item.price)")
            Text("稀有度：\(item.rarity)")
            Text("池塘：\(item.pond)")
            Text("描述：\(item.description)")
            Text("总数：\(item.totalCount)")
            Text("钓到的总数：\(item.fishedCount)")
            
            Button("关闭") {
                // sheet 自动关闭
            }
        }
        .padding()
    }
}

// MARK: - 预览
struct PlayerBackpackView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = PlayerBackpackManager.shared
        
        manager.selectedTab = .fishbusket
        return PlayerBackpackView(manager: manager, showPlayerBackpack: .constant(true))
    }
}
