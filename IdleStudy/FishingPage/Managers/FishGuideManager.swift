//
//  FishGuideManager.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/25.
//

import Foundation

/// 单条鱼在图鉴中的信息
/// - 包含了鱼的基本资料（名称、池塘、稀有度、最大最小重量、图片）
/// - 还包含玩家是否已发现、玩家曾钓到的最大/最小重量
struct FishGuideEntry: Identifiable, Codable {
    let id = UUID()
    
    let name: String
    let pond: String
    let rarity: String
    let minWeightPossible: Double
    let maxWeightPossible: Double
    let image: String
    
    /// 玩家是否已发现该鱼
    var discovered: Bool
    
    /// 玩家曾钓到的最小/最大重量（可能还没钓到则为 nil）
    var caughtMinWeight: Double?
    var caughtMaxWeight: Double?
}

/// 图鉴管理器：负责加载所有鱼的基础信息、记录玩家发现状态和钓到的极值
class FishGuideManager {
    static let shared = FishGuideManager()
    
    /// 是否开启“管理者模式”——只有在管理者模式下，才能清空图鉴
    var adminMode: Bool = false
    
    /// 内存中的图鉴数据
    private(set) var guideEntries: [FishGuideEntry] = []
    
    private let guideFileName = "FishGuide.json"
    
    private init() {
        // 启动时自动加载
        loadGuide()
    }
    
    /// 从本地/Bundle 的 FishDataset.json 加载所有鱼的基础信息，再与本地图鉴数据合并
    private func loadGuide() {
        // 1. 加载基础鱼数据
        guard let url = Bundle.main.url(forResource: "FishDataset", withExtension: "json") else {
            print("❌ 未找到 FishDataset.json 文件")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let baseFishes = try JSONDecoder().decode([Fish].self, from: data)
            
            // 2. 将基础数据转换成 FishGuideEntry 的“初始状态”（未发现）
            var baseEntries: [FishGuideEntry] = baseFishes.map { fish in
                FishGuideEntry(
                    name: fish.name,
                    pond: fish.pond,
                    rarity: fish.rarity,
                    minWeightPossible: fish.minimumWeight,
                    maxWeightPossible: fish.maximumWeight,
                    image: fish.image,
                    discovered: false,
                    caughtMinWeight: nil,
                    caughtMaxWeight: nil
                )
            }
            
            // 3. 读取本地图鉴进度（FishGuide.json），合并到 baseEntries 里
            if let loaded = try? loadLocalGuide() {
                // 按名字匹配，把 discovered / caughtMinWeight / caughtMaxWeight 合并过来
                for i in 0..<baseEntries.count {
                    if let savedEntry = loaded.first(where: { $0.name == baseEntries[i].name }) {
                        baseEntries[i].discovered = savedEntry.discovered
                        baseEntries[i].caughtMinWeight = savedEntry.caughtMinWeight
                        baseEntries[i].caughtMaxWeight = savedEntry.caughtMaxWeight
                    }
                }
            }
            
            // 最终赋值给 guideEntries
            self.guideEntries = baseEntries
        } catch {
            print("❌ FishGuideManager 加载失败：\(error)")
        }
    }
    
    /// 从沙盒中读取已存的图鉴进度
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
        let data = try JSONEncoder().encode(self.guideEntries)
        try data.write(to: url)
    }
    
    /// 计算沙盒里 FishGuide.json 的路径
    private func localGuideURL() throws -> URL {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FishGuideManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "无法获取 documentDirectory"])
        }
        return dir.appendingPathComponent(guideFileName)
    }
    
    // MARK: - 对外的功能方法
    
    /// 标记玩家发现了某条鱼（比如第一次钓到），并更新 caughtMinWeight/caughtMaxWeight
    func discoverFish(name: String, caughtWeight: Double?) {
        guard let index = guideEntries.firstIndex(where: { $0.name == name }) else {
            print("⚠️ discoverFish：未找到鱼 \(name)")
            return
        }
        
        // 标记已发现
        guideEntries[index].discovered = true
        
        // 如果有传入钓到的重量，就更新 caughtMinWeight/caughtMaxWeight
        if let w = caughtWeight {
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
        }
        
        // 保存到本地
        do {
            try saveLocalGuide()
        } catch {
            print("❌ 保存图鉴失败：\(error)")
        }
    }
    
    /// 更新玩家钓到的极值（如果已经发现该鱼）
    func updateCaughtWeight(name: String, newWeight: Double) {
        guard let index = guideEntries.firstIndex(where: { $0.name == name }) else {
            print("⚠️ updateCaughtWeight：未找到鱼 \(name)")
            return
        }
        // 如果尚未发现，也可以在这里顺便标记发现
        guideEntries[index].discovered = true
        
        // 更新极值
        if let oldMin = guideEntries[index].caughtMinWeight {
            guideEntries[index].caughtMinWeight = min(oldMin, newWeight)
        } else {
            guideEntries[index].caughtMinWeight = newWeight
        }
        
        if let oldMax = guideEntries[index].caughtMaxWeight {
            guideEntries[index].caughtMaxWeight = max(oldMax, newWeight)
        } else {
            guideEntries[index].caughtMaxWeight = newWeight
        }
        
        // 保存
        do {
            try saveLocalGuide()
        } catch {
            print("❌ 保存图鉴失败：\(error)")
        }
    }
    
    /// 清空图鉴：只有在 adminMode = true 时才能执行
    func clearGuide() {
        guard adminMode else {
            print("❌ 无法清空：必须在管理员模式下才可操作")
            return
        }
        
        // 将所有 discovered = false, caughtMinWeight = nil, caughtMaxWeight = nil
        for i in 0..<guideEntries.count {
            guideEntries[i].discovered = false
            guideEntries[i].caughtMinWeight = nil
            guideEntries[i].caughtMaxWeight = nil
        }
        
        do {
            try saveLocalGuide()
            print("✅ 已清空图鉴")
        } catch {
            print("❌ 清空图鉴失败：\(error)")
        }
    }
    
    //同步鱼篓
    func syncFromBusket() {
            do {
                let fishArray = try FishBusketManager.shared.loadFishArray()
                for fishDict in fishArray {
                    let fishInBusket = try FishInFishBusket.from(dictionary: fishDict)
                    
                    // 在图鉴里查找是否已有这条鱼
                    if let index = guideEntries.firstIndex(where: { $0.name == fishInBusket.name }) {
                        // 已存在：标记 discovered = true，更新最小/最大体重
                        guideEntries[index].discovered = true
                        let w = fishInBusket.weight
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
                        // 图鉴里没有这条鱼 —— 如果你支持动态添加，或者忽略
                        print("⚠️ 图鉴中未找到此鱼：\(fishInBusket.name)")
                    }
                }
                try saveLocalGuide()
                print("✅ syncFromBusket 完成")
            } catch {
                print("❌ syncFromBusket 失败：\(error)")
            }
    }
}

