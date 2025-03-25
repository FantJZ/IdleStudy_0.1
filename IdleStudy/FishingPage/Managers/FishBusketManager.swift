//
//  FishBusketManager.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/19.
//

import Foundation

/// 用于管理“鱼篓”数据的单例，与 FishingTreasureManager 类似的思路
final class FishBusketManager: ObservableObject {
    static let shared = FishBusketManager()
    
    /// 这里保存所有鱼篓中的鱼
    @Published var allFishes: [FishInFishBusket] = []
    
    /// 默认文件名，可自定义
    private let fileName = "FishBusket.json"
    
    /// 私有构造，在初始化时自动加载
    private init() {
        loadFishes()
    }
    
    // MARK: - 加载鱼篓数据
    /// 从 FishBusket.json 中读取，并解析成 [FishInFishBusket]
    private func loadFishes() {
        guard let url = fileURL else {
            print("❌ 无法获取 FishBusket.json 的文件路径")
            return
        }
        
        // 如果文件不存在，先创建一个空文件
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                let emptyData = try JSONEncoder().encode([FishInFishBusket]())
                try emptyData.write(to: url)
                print("ℹ️ 已创建空的 FishBusket.json")
            } catch {
                print("❌ 创建空 FishBusket.json 文件失败：\(error)")
                return
            }
        }
        
        do {
            let data = try Data(contentsOf: url)
            let fishes = try JSONDecoder().decode([FishInFishBusket].self, from: data)
            self.allFishes = fishes
            print("✅ 从 FishBusket.json 加载了 \(fishes.count) 条鱼")
        } catch {
            print("❌ 加载鱼篓数据失败：\(error)")
        }
    }
    
    // MARK: - 保存鱼篓数据
    /// 将内存中的 allFishes 数组写回 FishBusket.json
    func saveFishes() {
        guard let url = fileURL else {
            print("❌ FishBusket.json 路径获取失败")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(allFishes)
            try data.write(to: url, options: .atomicWrite)
            print("✅ 已将 \(allFishes.count) 条鱼保存到 FishBusket.json")
        } catch {
            print("❌ 保存鱼篓数据失败：\(error)")
        }
    }
    
    // MARK: - 清空鱼篓
    func removeAllFishes() {
        allFishes.removeAll()
        saveFishes()
        print("✅ 已清空鱼篓（内存 + 文件）")
    }
    
    // MARK: - 文件路径
    private var fileURL: URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return dir.appendingPathComponent(fileName)
    }
    
    // MARK: - 调试工具
    func debugFileStatus() {
        guard let url = fileURL else {
            print("❌ FishBusket.json 路径获取失败")
            return
        }
        
        print("📁 绝对路径：\(url.path)")
        print("🗂️ 文件存在：\(FileManager.default.fileExists(atPath: url.path) ? "✅" : "❌")")
        
        do {
            let data = try Data(contentsOf: url)
            let raw = try JSONSerialization.jsonObject(with: data)
            print("📦 文件内容结构：")
            dump(raw)
        } catch {
            print("❌ 内容读取失败：\(error)")
        }
    }
}
