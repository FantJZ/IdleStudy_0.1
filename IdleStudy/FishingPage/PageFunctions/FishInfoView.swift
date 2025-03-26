import SwiftUI

// MARK: - FishDataPopsOut
/// 负责：
/// 1. 在 onAppear 时调用 FishingManager 获取随机抽取的结果（鱼、垃圾或宝藏），并存储到 catchResult
/// 2. 根据 catchResult 中的稀有度动态设置背景渐变（鱼和宝藏根据稀有度，垃圾使用默认）
//—– 注意：如果抽取到的是鱼，还会执行加经验、同步图鉴、更新鱼数据以及保存鱼到鱼篓的功能
struct FishDataPopsOut: View {
    @EnvironmentObject var pondStore: PondStore
    @State private var catchResult: FishingCatch?
    
    var body: some View {
        ZStack {
            // 添加全屏半透明背景，突显弹窗效果
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // 原有弹出窗口卡片
            ZStack {
                // 背景卡片，根据鱼或宝藏的稀有度设置渐变；垃圾或未抽到时使用默认渐变
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(backgroundGradient(for: rarityFrom(catchResult: catchResult)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.7), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                
                // 展示抽取结果信息的视图
                NewFishInfoView(catchResult: catchResult)
                    .padding()
            }
            .frame(width: 240, height: 340)
            // 修改位置，使窗口正好居中显示
            .position(
                x: UIScreen.main.bounds.midX + 15,
                y: UIScreen.main.bounds.midY - 70
            )
        }
        .onAppear {
                    // 将 PondStore 注入到各管理器
                    FishingManager.shared.pondStore = pondStore
                    FishingGarbageManager.shared.pondStore = pondStore
                    FishingTreasureManager.shared.pondStore = pondStore

                    let result = FishingManager.shared.getRandomCatch()
                    self.catchResult = result

                    // 根据抽奖结果执行相应操作
                    if let result = result {
                        switch result {
                        case .fish(let info):
                            ExperienceManager.shared.addXP(info.exp)
                            FishGuideManager.shared.syncFromBusket()
                            FishDataManager.shared.updateFishInfo(info)
                            print("✅ 获取到的鱼信息: \(info)")
                            
                            // 1. 保存到本地文件（可选）
                            saveToBusket(fish: info)
                            
                            // 2. 同时添加到 PlayerBackpackManager 的 fishBusketItems 里
                            let newFish = FishInFishBusket(
                                image: info.image,
                                name: info.fishName,
                                quality: info.quality,
                                weight: info.weight,
                                price: info.price,
                                rarity: info.rarity,
                                exp: info.exp
                            )
                            PlayerBackpackManager.shared.fishBusketItems.append(newFish)
                            
                        case .garbage(let info):
                            let newGarbage = BackpackGarbageItem(
                                name: info.garbageName,
                                price: info.price,
                                pond: "未知",
                                description: info.description,
                                quantity: 1,
                                totalCount: 1,
                                fishedCount: 1,
                                image: info.image
                            )
                            // 不要直接 append 了，改为:
                            PlayerBackpackManager.shared.addGarbageItem(newGarbage)

                            
                        case .treasure(let info):
                            ExperienceManager.shared.addXP(info.exp)
                            
                            let newTreasure = BackpackTreasureItem(
                                name: info.treasureName,
                                price: info.price,
                                pond: info.pond,
                                rarity: info.rarity,
                                exp: info.exp,
                                description: info.description,
                                quantity: 1,
                                totalCount: 1,
                                fishedCount: 1
                            )
                            PlayerBackpackManager.shared.addTreasureItem(newTreasure)

                        }
                    }
                }
    }
    
    /// 将当前鱼信息追加保存到鱼篓（仅对鱼类型调用）
    private func saveToBusket(fish: FishInfoItem) {
        let newFish = FishInFishBusket(
            image: fish.image,
            name: fish.fishName,
            quality: fish.quality,
            weight: fish.weight,
            price: fish.price,
            rarity: fish.rarity,
            exp: fish.exp
        )
        
        // 1. 先放到内存数组里
        FishBusketManager.shared.allFishes.append(newFish)
        
        // 2. 调用 saveFishes() 写入本地文件
        FishBusketManager.shared.saveFishes()
        print("✅ 已追加保存一条新鱼: \(newFish)")
        
        // 3. 验证读取到的数据（其实就是内存里的 allFishes）
        let allFishes = FishBusketManager.shared.allFishes
        print("✅ 验证读取到的数据：\(allFishes)")
        
        // 4. 调试输出
        FishBusketManager.shared.debugFileStatus()
    }
    
    /// 根据 catchResult（鱼或宝藏）获取稀有度，用于设置背景渐变
    private func rarityFrom(catchResult: FishingCatch?) -> String? {
        if let result = catchResult {
            switch result {
            case .fish(let info):
                return info.rarity
            case .treasure(let info):
                return info.rarity
            default:
                return nil
            }
        }
        return nil
    }
    
    /// 根据稀有度返回不同背景渐变
    private func backgroundGradient(for rarity: String?) -> LinearGradient {
        switch rarity {
        case "普通":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.4),
                    Color.gray.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "稀有":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.4),
                    Color.blue.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "史诗":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.4),
                    Color.purple.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "传说":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.yellow.opacity(0.5),
                    Color.orange.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "至臻":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.red.opacity(0.4),
                    Color.red.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            // 默认：蓝紫渐变
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.4),
                    Color.purple.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - NewFishInfoView
/// 新的 FishInfoView：根据 FishingManager 抽取的结果展示不同内容，并设置不同的边框
struct NewFishInfoView: View {
    let catchResult: FishingCatch?
    
    var body: some View {
        VStack {
            if let result = catchResult {
                switch result {
                case .fish(let info):
                    infoView(
                        title: "鱼",
                        name: info.fishName,
                        quality: info.quality,
                        weight: info.weight,
                        price: info.price,
                        rarity: info.rarity,
                        exp: info.exp,
                        image: info.image
                    )
                case .garbage(let info):
                    infoView(
                        title: "垃圾",
                        name: info.garbageName,
                        quality: nil,
                        weight: nil,
                        price: info.price,
                        rarity: nil,
                        exp: nil,
                        image: info.image,
                        description: info.description
                    )
                case .treasure(let info):
                    infoView(
                        title: "宝藏",
                        name: info.treasureName,
                        quality: nil,
                        weight: nil,
                        price: info.price,
                        rarity: info.rarity,
                        exp: info.exp,
                        image: info.image,
                        description: info.description
                    )
                }
            } else {
                Text("还未捕获任何东西")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func infoView(title: String, name: String, quality: String?, weight: Double?, price: Int, rarity: String?, exp: Int?, image: String, description: String? = nil) -> some View {
        VStack(spacing: 16) {
            if !image.isEmpty {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            } else {
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }
            
            Text(title)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("名称：\(name)")
                if let quality = quality {
                    Text("品质：\(quality)")
                }
                if let weight = weight {
                    Text(String(format: "重量：%.2f kg", weight))
                }
                Text("价格：\(price)")
                if let rarity = rarity {
                    Text("稀有度：\(rarity)")
                }
                if let exp = exp {
                    Text("经验值：\(exp)")
                }
                if let desc = description, !desc.isEmpty {
                    Text("描述：\(desc)")
                }
            }
            .font(.subheadline)
        }
        .padding()
    }
}

#Preview {
    FishDataPopsOut()
        .environmentObject(PondStore())
}
