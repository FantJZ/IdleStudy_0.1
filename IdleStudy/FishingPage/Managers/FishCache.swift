import Foundation
import SwiftUI

final class FishCache: ObservableObject {
    static let shared = FishCache()
    
    /// 缓存：所有鱼数据
    var allFishes: [Fish] = []
    
    /// 让 FishCache 能访问 PondStore
    /// 你可以在 App 启动时或合适的地方为它赋值
    @Published var pondStore: PondStore? = nil
    
    private init() {
        self.allFishes = self.loadFishes() ?? []
    }
    
    /// 加载本地 JSON 文件，解析成 [Fish]
    private func loadFishes() -> [Fish]? {
        guard let url = Bundle.main.url(forResource: "FishDataset", withExtension: "json") else {
            print("无法找到 FishDataset.json 文件")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let fishArray = try JSONDecoder().decode([Fish].self, from: data)
            return fishArray
        } catch {
            print("解析 JSON 数据出错：\(error)")
            return nil
        }
    }
    
    /// 无参方法：根据 PondStore 里选定的池塘名称，随机抽取一条鱼信息
    func fishInfo() -> FishInfoItem? {
        // 1. 获取 PondStore 中的 selectedPond
        guard let pondName = pondStore?.selectedPond?.name else {
            print("⚠️ 未选定池塘，无法生成鱼")
            return nil
        }
        
        // 2. 在 allFishes 里筛选 pond == pondName 的鱼
        let pondFishes = allFishes.filter { $0.pond == pondName }
        
        // 3. 通过随机事件，得到一个 1~5 的结果，用于映射到稀有度
        guard let result = RandomEvent(5, 10, 6, 3, 1, 0.1) else {
            return nil
        }
        
        let targetRarity: String
        switch result {
        case 1: targetRarity = "普通"
        case 2: targetRarity = "稀有"
        case 3: targetRarity = "史诗"
        case 4: targetRarity = "传说"
        case 5: targetRarity = "至珍"
        default: return nil
        }
        
        // 4. 在 pondFishes 中筛选出该稀有度的所有鱼
        let candidates = pondFishes.filter { $0.rarity == targetRarity }
        
        // 5. 从 candidates 中随机取一条
        guard let randomFish = candidates.randomElement() else {
            print("⚠️ \(pondName) 没有稀有度为 \(targetRarity) 的鱼")
            return nil
        }
        
        // 6. 返回这条鱼对应的 infoItem
        return randomFish.infoItem
    }
}
