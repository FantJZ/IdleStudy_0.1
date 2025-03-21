//
//  FishCache.swift
//  IdleStudy
//
//  Created by 大大 on 2025/3/19.
//

import Foundation

// MARK: - FishDataCache

final class FishCache {
    static let shared = FishCache()
    /// 缓存
    var allFishes: [Fish] = []
    
    private init() {
        self.allFishes = self.loadFishes() ?? []
    }
    
    /// 加载本地 JSON 文件，解析成 [Fish]
    private func loadFishes() -> [Fish]? {
        // 这里的 "FishDataset" 对应你的 JSON 文件名
        guard let url = Bundle.main.url(forResource: "FishDataset", withExtension: "json") else {
            print("无法找到 fish.json 文件")
            return nil
        }
        
        do {
            // 读取文件数据
            let data = try Data(contentsOf: url)
            // 使用 JSONDecoder 将数据解码成 Fish 数组
            let fishArray = try JSONDecoder().decode([Fish].self, from: data)
            return fishArray
        } catch {
            print("解析 JSON 数据出错：\(error)")
            return nil
        }
    }
    
    /// 根据池塘名，随机抽取一条鱼信息
    func fishInfo(_ pondName: String) -> FishInfoItem? {
        // 1. 获取在 pondName 中的所有鱼
        let pondFishes = allFishes.filter { $0.pond == pondName }
        
        // 2. 通过随机事件，得到一个 1~5 的结果，用于映射到稀有度
        guard let result = RandomEvent(5, 10, 6, 3, 1, 0.1) else {
            return nil
        }
        
        // 3. 根据 result 确定稀有度
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
            // 如果该池塘没有这种稀有度的鱼，就返回 nil
            return nil
        }
        
        // 6. 返回这条鱼对应的 infoItem
        return randomFish.infoItem
    }
}

