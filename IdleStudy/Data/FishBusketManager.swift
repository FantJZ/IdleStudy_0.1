//
//  FishBusketManager.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/19.
//

import Foundation

//extension FishBusketManager {
//    /// 将字典写入 FishBusket.json
//    /// - Parameter dictionary: 要存储的字典（值需符合 Codable）
//    static func writeToFishBusket<T: Codable>(_ dictionary: [String: T]) throws {
//        try shared.save(dictionary)
//    }
//
//    /// 通用版本（处理包含混合类型的字典）
//    static func writeToFishBusket(_ dictionary: [String: Any]) throws {
//        let data = try JSONSerialization.data(
//            withJSONObject: dictionary,
//            options: [.prettyPrinted, .sortedKeys]
//        )
//        guard let url = shared.fileURL else {
//            throw FileError.invalidPath
//        }
//        try data.write(to: url)
//    }
//}

//func saveToBusket() {
//    guard let fish = FishDataManager.shared.currentFishInfo else {
//        print("⚠️ 没有可保存的鱼数据")
//        return
//    }
//    
//    let fishDict: [String: Any] = [ // 移除可选类型声明
//        "image": fish.image,
//        "name": fish.fishName,
//        "quality": fish.quality,
//        "weight": fish.weight,
//        "price": fish.price,
//        "rarity": fish.rarity
//    ]
//    
//    do {
//        try FishBusketManager.shared.saveDictionary(fishDict) // 直接传递字典
//        print("✅ 字典存储成功")
//    } catch FishBusketManager.FileError.encodingFailed {
//        print("❌ 数据编码失败")
//    } catch {
//        print("❌ 其他错误：\(error)")
//    }
//}

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
    
    // MARK: - 字典专用方法
    /// 保存字典到文件
    func saveDictionary(_ dictionary: [String: Any]) throws {
        guard let url = fileURL else {
            throw FileError.invalidPath
        }
        
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
    
    /// 从文件加载字典
    func loadDictionary() throws -> [String: Any] {
        guard let url = fileURL else {
            throw FileError.invalidPath
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw FileError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw FileError.decodingFailed
            }
            return dict
        } catch {
            throw FileError.decodingFailed
        }
    }
  
    func debugFileStatus() {
            guard let url = fileURL else {
                print("❌ 路径获取失败")
                return
            }
            
            print("📁 绝对路径：\(url.path)")
            print("🗂️ 文件存在：\(FileManager.default.fileExists(atPath: url.path) ? "✅" : "❌")")
        }
    
//    // MARK: - 原 Codable 方法（保留兼容性）
//    func save<T: Codable>(_ object: T) throws { /* 原实现保持不变 */ }
//    func load<T: Codable>() throws -> T { /* 原实现保持不变 */ }
    
    // MARK: - 错误类型
    enum FileError: Error {
        case invalidPath
        case fileNotFound
        case decodingFailed
        case encodingFailed
    }
}



// MARK: - 使用示例
// MARK: 存储字典
//let fishDict: [String: Any] = [
//    "image": "golden_fish",
//    "name": "黄金鱼",
//    "quality": "传说",
//    "weight": 4.8,
//    "price": 8888,
//    "rarity": "UR"
//]
//
//do {
//    try FishBusketManager.shared.saveDictionary(fishDict)
//    print("✅ 字典存储成功")
//} catch FishBusketManager.FileError.encodingFailed {
//    print("❌ 数据编码失败")
//} catch {
//    print("❌ 其他错误：\(error)")
//}

// MARK: 读取字典
//do {
//    let loadedDict = try FishBusketManager.shared.loadDictionary()
//    print("读取到的字典内容：")
//    dump(loadedDict)  // 更清晰的打印方式
//    
//    // 访问具体值
//    if let weight = loadedDict["weight"] as? Double {
//        print("当前重量：\(weight)kg")
//    }
//} catch FishBusketManager.FileError.decodingFailed {
//    print("❌ 数据解析失败")
//} catch {
//    print("❌ 其他错误：\(error)")
//}

