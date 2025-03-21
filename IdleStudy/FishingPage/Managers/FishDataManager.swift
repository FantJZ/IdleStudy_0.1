//
//  FishDataManager.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/19.
//

import Foundation

class FishDataManager {
    static let shared = FishDataManager()
    
    // 使用和视图层完全一致的数据结构
    private(set) var currentFishInfo: FishInfoItem?
    
    // 线程安全的数据更新方法
    func updateFishInfo(_ info: FishInfoItem) {
        DispatchQueue.main.async {
            self.currentFishInfo = info
        }
    }
    
    private init() {}  // 确保单例模式
}

