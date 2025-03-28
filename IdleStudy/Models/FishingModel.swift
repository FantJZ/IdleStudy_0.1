
// File: Models/FishInFishBusket.swift
import Foundation

struct FishInFishBusket: Identifiable, Codable {
    let id = UUID()
    let image: String
    let name: String
    let quality: String
    let weight: Double
    let price: Int
    let rarity: String
    let exp: Int
    
    enum CodingKeys: String, CodingKey {
        case image, name, quality, weight, price, rarity, exp
    }
}

// MARK: - 垃圾模型
struct Garbage: Codable {
    let name: String
    let image: String
    let price: Int
    let pond: String
    let description: String

    // 计算属性，生成垃圾信息（类似 FishInfoItem）
    var infoItem: GarbageInfoItem {
        GarbageInfoItem(
            garbageName: name,
            price: price,
            image: image,
            description: description
        )
    }
}

// MARK: - 垃圾信息结构体

struct GarbageInfoItem {
    let garbageName: String
    let price: Int
    let image: String
    let description: String
}



// MARK: - Treasure 模型

struct Treasure: Codable {
    let name: String
    let image: String
    let price: Int
    let rarity: String
    let exp: Int
    let pond: String
    let description: String

    // 生成宝藏信息（类似 FishInfoItem）
    var infoItem: TreasureInfoItem {
        TreasureInfoItem(
            treasureName: name,
            price: price,
            rarity: rarity,
            exp: exp,
            image: image,
            pond: pond,
            description: description
        )
    }
}

// MARK: - TreasureInfoItem

struct TreasureInfoItem {
    let treasureName: String
    let price: Int
    let rarity: String
    let exp: Int
    let image: String
    let pond: String
    let description: String
}

//// MARK: - StoreItem
//struct StoreItem: Identifiable, Codable, Hashable {
//    var id = UUID()
//    var name: String
//    var image: String
//    var price: Int
//    let description: String
//}
//
//struct StoreItemRaw: Codable {
//    let tab: String
//    let name: String
//    let image: String
//    let price: Int
//    let description: String
//}
