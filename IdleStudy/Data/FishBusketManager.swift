//
//  FishBusketManager.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/19.
//

import Foundation

class FishBusketManager {
    static let shared = FishBusketManager()
    private let fileName = "FishBusket.json"
    
    // MARK: - 文件路径
    private var fileURL: URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return dir.appendingPathComponent(fileName)
    }
    
    // MARK: - 改进的字典操作方法
    /// 保存单条鱼数据
    func saveFish(_ fish: FishInFishBusket) throws {
        var currentData = (try? loadAllFishes()) ?? [:]
        let fishID = UUID().uuidString
        currentData[fishID] = try fish.toDictionary()
        try saveAllFishes(currentData)
    }
    
    /// 加载全部鱼数据，返回格式为 [鱼ID: 鱼数据字典]
    func loadAllFishes() throws -> [String: [String: Any]] {
        guard let url = fileURL else { throw FileError.invalidPath }
        
        // 自动创建空文件
        if !FileManager.default.fileExists(atPath: url.path) {
            try saveAllFishes([:])
        }
        
        let data = try Data(contentsOf: url)
        let rawDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        // 数据迁移检查
        return try migrateDataStructure(rawDict)
    }
    
    /// 新增方法：直接返回鱼数据数组，便于遍历解码
    func loadFishArray() throws -> [[String: Any]] {
        let allFishes = try loadAllFishes()
        return Array(allFishes.values)
    }
    
    // MARK: - 私有方法
    private func saveAllFishes(_ dictionary: [String: [String: Any]]) throws {
        guard let url = fileURL else { throw FileError.invalidPath }
        
        do {
            let data = try JSONSerialization.data(
                withJSONObject: dictionary,
                options: [.prettyPrinted, .sortedKeys]
            )
            try data.write(to: url)
        } catch {
            throw FileError.encodingFailed
        }
    }
    
    /// 数据迁移（处理旧版数据结构）
    private func migrateDataStructure(_ rawData: [String: Any]) throws -> [String: [String: Any]] {
        // 检测是否是旧版数据（没有嵌套结构）
        let isLegacyData = rawData.values.contains { $0 is String || $0 is Double }
        
        if isLegacyData {
            print("⚠️ 检测到旧版数据格式，正在迁移...")
            let fishID = UUID().uuidString
            return [fishID: rawData]
        }
        
        // 已经是新版结构的转换
        guard let validData = rawData as? [String: [String: Any]] else {
            throw FileError.decodingFailed
        }
        
        return validData
    }
    
    // MARK: - 调试工具
    func debugFileStatus() {
        guard let url = fileURL else {
            print("❌ 路径获取失败")
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
    
    // MARK: - 错误类型
    enum FileError: Error {
        case invalidPath
        case fileNotFound
        case decodingFailed
        case encodingFailed
        case migrationFailed
    }
}

// MARK: - 数据模型扩展
extension FishInFishBusket {
    func toDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
    
    static func from(dictionary: [String: Any]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try JSONDecoder().decode(Self.self, from: data)
    }
}

// MARK: - 为兼容其他页面（例如 FishInfoView）新增字典读写方法
extension FishBusketManager {
    /// 保存一个字典数据
    func saveDictionary(_ dictionary: [String: Any]) throws {
        // 判断数据格式：如果数据不是嵌套格式，则视为旧版数据，需要包装后保存
        if dictionary.values.contains(where: { !($0 is [String: Any]) }) {
            let fishID = UUID().uuidString
            try saveAllFishes([fishID: dictionary])
        } else if let nestedDict = dictionary as? [String: [String: Any]] {
            try saveAllFishes(nestedDict)
        } else {
            throw FileError.encodingFailed
        }
    }
    
    /// 加载字典数据（兼容其他页面调用，合并所有鱼数据）
    func loadDictionary() throws -> [String: Any] {
        let allFishes = try loadAllFishes()
        // 如果只有一条数据（旧版数据迁移后），直接返回其内容
        if allFishes.count == 1, let value = allFishes.values.first {
            return value
        } else {
            // 否则将所有鱼数据合并成一个字典返回
            var merged: [String: Any] = [:]
            for (_, dict) in allFishes {
                for (k, v) in dict {
                    merged[k] = v
                }
            }
            return merged
        }
    }
}

