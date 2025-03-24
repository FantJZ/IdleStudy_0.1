//
//  FishingManager.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/23.
//

import Foundation
import SwiftUI

/// 定义抽取到的结果类型
enum FishingCatch {
    case fish(FishInfoItem)
    case garbage(GarbageInfoItem)
    case treasure(TreasureInfoItem)
}

/// 定义概率配置结构体
struct CatchProbability {
    let fish: Double
    let garbage: Double
    let treasure: Double
}

/// FishingManager 根据当前选定的池塘随机抽取鱼、垃圾或宝藏
final class FishingManager: ObservableObject {
    static let shared = FishingManager()
    
    /// 当前池塘信息（需要在适当时机赋值）
    @Published var pondStore: PondStore? = nil
    
    /// 针对特定池塘的概率配置
    private let pondProbabilities: [String: CatchProbability] = [
        "邻居家的池塘": CatchProbability(fish: 40, garbage: 50, treasure: 10)
        // 可在此处为其他池塘添加不同配置
    ]
    
    /// 默认概率配置（用于未配置的池塘）
    private let defaultProbability = CatchProbability(fish: 60, garbage: 30, treasure: 10)
    
    private init() {}
    
    /// 根据当前池塘和概率随机抽取一个结果
    func getRandomCatch() -> FishingCatch? {
        // 1. 获取当前选定的池塘名称
        guard let pondName = pondStore?.selectedPond?.name else {
            print("⚠️ 未选定池塘，无法抽取")
            return nil
        }
        
        // 2. 获取该池塘对应的概率配置（没有配置则使用默认）
        let probability = pondProbabilities[pondName] ?? defaultProbability
        
        // 3. 利用 RandomEvent 方法生成 1 ~ 3 的随机结果
        //    1 → 鱼，2 → 垃圾，3 → 宝藏
        guard let eventResult = RandomEvent(3, probability.fish, probability.garbage, probability.treasure) else {
            return nil
        }
        
        // 4. 根据结果返回对应的抽取项
        switch eventResult {
        case 1:
            if let fishItem = FishCache.shared.fishInfo() {
                return .fish(fishItem)
            }
        case 2:
            if let garbageItem = FishingGarbageManager.shared.garbageInfo() {
                return .garbage(garbageItem)
            }
        case 3:
            if let treasureItem = FishingTreasureManager.shared.treasureInfo() {
                return .treasure(treasureItem)
            }
        default:
            return nil
        }
        return nil
    }
}
