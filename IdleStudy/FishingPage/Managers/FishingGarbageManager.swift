//
//  FishingGarbageManager.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/23.
//

import Foundation
import SwiftUI

// MARK: - FishingGarbageManager

final class FishingGarbageManager: ObservableObject {
    static let shared = FishingGarbageManager()
    
    /// 缓存：所有垃圾数据
    var allGarbage: [Garbage] = []
    
    /// 用于访问 PondStore（需要在合适时机赋值）
    @Published var pondStore: PondStore? = nil
    
    private init() {
        self.allGarbage = loadGarbage() ?? []
    }
    
    /// 加载本地 JSON 文件，解析成 [Garbage]
    private func loadGarbage() -> [Garbage]? {
        guard let url = Bundle.main.url(forResource: "FishingGarbage", withExtension: "json") else {
            print("无法找到 FishingGarbage.json 文件")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let garbageArray = try JSONDecoder().decode([Garbage].self, from: data)
            return garbageArray
        } catch {
            print("解析垃圾 JSON 数据出错：\(error)")
            return nil
        }
    }
    
    /// 根据 PondStore 中选定的池塘名称，随机抽取一条垃圾信息
    func garbageInfo() -> GarbageInfoItem? {
        // 1. 获取 PondStore 中的 selectedPond
        guard let pondName = pondStore?.selectedPond?.name else {
            print("⚠️ 未选定池塘，无法生成垃圾")
            return nil
        }
        
        // 2. 在 allGarbage 中筛选出对应池塘的垃圾
        let pondGarbage = allGarbage.filter { $0.pond == pondName }
        
        // 3. 随机取一条垃圾
        guard let randomGarbage = pondGarbage.randomElement() else {
            print("⚠️ \(pondName) 没有垃圾")
            return nil
        }
        
        // 4. 返回这条垃圾对应的信息
        return randomGarbage.infoItem
    }
}
