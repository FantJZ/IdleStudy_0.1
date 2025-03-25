//
//  FishGuideManager.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/25.
//

import Foundation

/// 单条鱼在图鉴中的信息
struct FishGuideEntry: Identifiable, Codable {
    let id = UUID()
    
    let name: String
    let pond: String
    let rarity: String
    let minWeightPossible: Double
    let maxWeightPossible: Double
    let image: String
    let exp: Int
    
    /// 玩家是否已发现该鱼
    var discovered: Bool
    
    /// 玩家曾钓到的最小/最大重量（可能还没钓到则为 nil）
    var caughtMinWeight: Double?
    var caughtMaxWeight: Double?
    
    /// 玩家钓到该鱼的总次数
    var caughtCount: Int
}

/// 图鉴管理器
final class FishGuideManager {
    static let shared = FishGuideManager()
    
    /// 是否开启“管理者模式”
    var adminMode: Bool = false
    
    /// 图鉴的内存数据
    private(set) var guideEntries: [FishGuideEntry] = []
    
    private let guideFileName = "FishGuide.json"
    
    private init() {
        // 启动时自动加载
        loadGuide()
    }
    
    // MARK: - 加载图鉴
    
    /// 从 Bundle 的 FishDataset.json 加载基础鱼信息，再与本地 FishGuide.json 合并
    private func loadGuide() {
        guard let url = Bundle.main.url(forResource: "FishDataset", withExtension: "json") else {
            print("❌ 未找到 FishDataset.json 文件")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let baseFishes = try JSONDecoder().decode([Fish].self, from: data)
            
            // 将基础数据转换成初始的 FishGuideEntry（未发现）
            var baseEntries: [FishGuideEntry] = baseFishes.map { fish in
                FishGuideEntry(
                    name: fish.name,
                    pond: fish.pond,
                    rarity: fish.rarity,
                    minWeightPossible: fish.minimumWeight,
                    maxWeightPossible: fish.maximumWeight,
                    image: fish.image,
                    exp: fish.exp,
                    discovered: false,
                    caughtMinWeight: nil,
                    caughtMaxWeight: nil,
                    caughtCount: 0
                )
            }
            
            // 读取本地图鉴进度（FishGuide.json），合并到 baseEntries
            if let loaded = try? loadLocalGuide() {
                for i in 0..<baseEntries.count {
                    if let savedEntry = loaded.first(where: { $0.name == baseEntries[i].name }) {
                        baseEntries[i].discovered = savedEntry.discovered
                        baseEntries[i].caughtMinWeight = savedEntry.caughtMinWeight
                        baseEntries[i].caughtMaxWeight = savedEntry.caughtMaxWeight
                        baseEntries[i].caughtCount = savedEntry.caughtCount
                    }
                }
            }
            
            self.guideEntries = baseEntries
        } catch {
            print("❌ FishGuideManager 加载失败：\(error)")
        }
    }
    
    /// 从沙盒读取已存的图鉴进度
    private func loadLocalGuide() throws -> [FishGuideEntry] {
        let url = try localGuideURL()
        if !FileManager.default.fileExists(atPath: url.path) {
            return []
        }
        let data = try Data(contentsOf: url)
        let loaded = try JSONDecoder().decode([FishGuideEntry].self, from: data)
        return loaded
    }
    
    /// 将当前 guideEntries 保存到沙盒
    private func saveLocalGuide() throws {
        let url = try localGuideURL()
        let data = try JSONEncoder().encode(guideEntries)
        try data.write(to: url)
    }
    
    /// 计算沙盒里 FishGuide.json 的路径
    private func localGuideURL() throws -> URL {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FishGuideManager", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "无法获取 documentDirectory"])
        }
        return dir.appendingPathComponent(guideFileName)
    }
    
    // MARK: - 新增：记录每条钓到的鱼
    
    /// 每当用户钓到一条鱼时，调用此方法将其记录到图鉴
    /// - 如果该鱼尚未发现，则标记 discovered = true
    /// - 更新 caughtMinWeight / caughtMaxWeight
    /// - caughtCount += 1
    func recordCaughtFish(_ fish: FishInFishBusket) {
        guard let index = guideEntries.firstIndex(where: { $0.name == fish.name }) else {
            print("⚠️ recordCaughtFish：图鉴中未找到鱼 \(fish.name)")
            return
        }
        
        // 标记已发现
        guideEntries[index].discovered = true
        
        // 更新最小 / 最大重量
        let w = fish.weight
        if let oldMin = guideEntries[index].caughtMinWeight {
            guideEntries[index].caughtMinWeight = min(oldMin, w)
        } else {
            guideEntries[index].caughtMinWeight = w
        }
        
        if let oldMax = guideEntries[index].caughtMaxWeight {
            guideEntries[index].caughtMaxWeight = max(oldMax, w)
        } else {
            guideEntries[index].caughtMaxWeight = w
        }
        
        // 钓到次数 +1
        guideEntries[index].caughtCount += 1
        
        // 保存
        do {
            try saveLocalGuide()
        } catch {
            print("❌ 保存图鉴失败：\(error)")
        }
    }
    
    // MARK: - 批量同步：从 FishBusketManager 中读取所有鱼，统一更新图鉴
    
    /// 读取 FishBusketManager.shared.allFishes（数组方式），批量更新图鉴
    func syncFromBusket() {
        let fishArray = FishBusketManager.shared.allFishes
        
        // 先统计“同名鱼”出现的次数
        var nameCountMap = [String: Int]()
        
        for fish in fishArray {
            let name = fish.name
            let w = fish.weight
            
            nameCountMap[name, default: 0] += 1
            
            // 标记图鉴已发现，并更新极值
            if let index = guideEntries.firstIndex(where: { $0.name == name }) {
                guideEntries[index].discovered = true
                if let oldMin = guideEntries[index].caughtMinWeight {
                    guideEntries[index].caughtMinWeight = min(oldMin, w)
                } else {
                    guideEntries[index].caughtMinWeight = w
                }
                if let oldMax = guideEntries[index].caughtMaxWeight {
                    guideEntries[index].caughtMaxWeight = max(oldMax, w)
                } else {
                    guideEntries[index].caughtMaxWeight = w
                }
            } else {
                print("⚠️ 图鉴中未找到此鱼：\(name)")
            }
        }
        
        // caughtCount = 在鱼篓中出现的数量
        for (name, count) in nameCountMap {
            if let index = guideEntries.firstIndex(where: { $0.name == name }) {
                guideEntries[index].caughtCount = count
            }
        }
        
        do {
            try saveLocalGuide()
            print("✅ syncFromBusket 完成：更新了图鉴信息")
        } catch {
            print("❌ syncFromBusket 失败：\(error)")
        }
    }
    
    // MARK: - 管理员模式下的功能
    
    /// 清空图鉴
    func clearGuide() {
        guard adminMode else {
            print("❌ 无法清空：必须在管理员模式下才可操作")
            return
        }
        for i in 0..<guideEntries.count {
            guideEntries[i].discovered = false
            guideEntries[i].caughtMinWeight = nil
            guideEntries[i].caughtMaxWeight = nil
            guideEntries[i].caughtCount = 0
        }
        do {
            try saveLocalGuide()
            print("✅ 已清空图鉴")
        } catch {
            print("❌ 清空图鉴失败：\(error)")
        }
    }
    
    /// 解锁所有鱼
    func unlockAllFishes() {
        guard adminMode else { return }
        for i in 0..<guideEntries.count {
            guideEntries[i].discovered = true
        }
        do { try saveLocalGuide() } catch { print("❌ unlockAllFishes 失败: \(error)") }
    }
    
    /// 为所有鱼“添加炫彩”
    func setAllRainbow() {
        guard adminMode else { return }
        for i in 0..<guideEntries.count {
            guideEntries[i].discovered = true
            guideEntries[i].caughtMaxWeight = guideEntries[i].maxWeightPossible
        }
        do { try saveLocalGuide() } catch { print("❌ setAllRainbow 失败: \(error)") }
    }
    
    /// 设置所有鱼的 caughtCount
    func setAllCaughtCount(to count: Int) {
        guard adminMode else { return }
        for i in 0..<guideEntries.count {
            guideEntries[i].discovered = true
            guideEntries[i].caughtCount = count
        }
        do { try saveLocalGuide() } catch { print("❌ setAllCaughtCount 失败: \(error)") }
    }
}
