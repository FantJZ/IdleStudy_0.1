//
//  FishingTreasureManager.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/23.
//

import Foundation
import SwiftUI

// MARK: - FishingTreasureManager

final class FishingTreasureManager: ObservableObject {
    static let shared = FishingTreasureManager()
    
    /// 缓存：所有宝藏数据
    var allTreasures: [Treasure] = []
    
    /// 用于访问 PondStore（需要在合适的时机赋值）
    @Published var pondStore: PondStore? = nil

    private init() {
        self.allTreasures = loadTreasures() ?? []
    }
    
    /// 加载本地 JSON 文件，解析成 [Treasure]
    private func loadTreasures() -> [Treasure]? {
        guard let url = Bundle.main.url(forResource: "FishingTreasure", withExtension: "json") else {
            print("无法找到 FishingTreasure.json 文件")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let treasureArray = try JSONDecoder().decode([Treasure].self, from: data)
            return treasureArray
        } catch {
            print("解析 FishingTreasure.json 数据出错：\(error)")
            return nil
        }
    }
    
    /// 根据 PondStore 中选定的池塘名称和随机生成的稀有度，随机抽取一个宝藏信息
    func treasureInfo() -> TreasureInfoItem? {
        // 1. 获取当前选定的池塘名称
        guard let pondName = pondStore?.selectedPond?.name else {
            print("⚠️ 未选定池塘，无法生成宝藏")
            return nil
        }
        
        // 2. 筛选出该池塘的宝藏数据
        let pondTreasures = allTreasures.filter { $0.pond == pondName }
        
        // 3. 根据概率生成一个 1~5 的随机结果，并映射为目标稀有度
        guard let rarityResult = RandomEvent(5, 10, 6, 3, 1, 0.1) else {
            return nil
        }
        
        let targetRarity: String
        switch rarityResult {
        case 1: targetRarity = "普通"
        case 2: targetRarity = "稀有"
        case 3: targetRarity = "史诗"
        case 4: targetRarity = "传说"
        case 5: targetRarity = "至臻"
        default:
            return nil
        }
        
        // 4. 在该池塘宝藏中筛选出符合目标稀有度的宝藏
        let candidates = pondTreasures.filter { $0.rarity == targetRarity }
        
        // 5. 随机返回一个宝藏
        guard let randomTreasure = candidates.randomElement() else {
            print("⚠️ \(pondName) 没有稀有度为 \(targetRarity) 的宝藏")
            return nil
        }
        
        return randomTreasure.infoItem
    }
}
