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

  private func loadFishes() -> [Fish]? {
    // 获取 Bundle 中的 fish.json 文件路径
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

  func fishInfo(_ pondName: String) -> FishInfoItem? {
    func readfishName(result: Int?, pondFishes: [Fish]) -> String {
      switch result {
      case 1:
        if let fish = pondFishes.first(where: { $0.rarity == "普通" }) {
          return fish.name
        }
      case 2:
        if let fish = pondFishes.first(where: { $0.rarity == "稀有" }) {
          return fish.name
        }
      case 3:
        if let fish = pondFishes.first(where: { $0.rarity == "史诗" }) {
          return fish.name
        }
      case 4:
        if let fish = pondFishes.first(where: { $0.rarity == "传说" }) {
          return fish.name
        }
      case 5:
        if let fish = pondFishes.first(where: { $0.rarity == "至珍" }) {
          return fish.name
        }
      default:
        break
      }
      return ""
    }
    
    let name = readfishName(result: RandomEvent(5, 10, 6, 3, 1, 0.1), pondFishes: self.allFishes.filter { $0.pond == pondName })
    
    return allFishes.filter { $0.name == name }.first?.infoItem
  }
}
