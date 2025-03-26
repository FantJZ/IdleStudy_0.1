//
//  BackgroundTimeManager.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/30.
//

import Foundation

/// 用于计算 App 从后台到再次激活的时间差
/// - 使用 UserDefaults 存储上次退出时间
/// - 提供方法获取“距离上次退出”到“当前”的秒数
final class BackgroundTimeManager {
    
    static let shared = BackgroundTimeManager()
    
    /// 用于在 UserDefaults 中存储上次退出时间的 key
    private let lastExitKey = "BackgroundTimeManager.lastExitDate"
    
    /// 私有构造，单例模式
    private init() { }
    
    // MARK: - 记录退出时间
    /// 在 App 进入后台 (或被挂起) 时调用，记录当前时间
    func recordExitTime() {
        let now = Date()
        UserDefaults.standard.set(now, forKey: lastExitKey)
        UserDefaults.standard.synchronize()
        print("✅ 已记录退出时间：\(now)")
    }
    
    // MARK: - 获取时间差（秒）
    /// 计算距离上次退出的秒数，如果从未记录过则返回 0
    func secondsSinceLastExit() -> Int {
        guard let lastExit = UserDefaults.standard.object(forKey: lastExitKey) as? Date else {
            // 如果从未记录过退出时间，直接返回 0
            return 0
        }
        let now = Date()
        let diff = now.timeIntervalSince(lastExit) // 单位：秒 (Double)
        let diffInt = Int(diff)
        print("⏱ 距离上次退出已过去 \(diffInt) 秒")
        return diffInt
    }
    
    // MARK: - 清空记录（新增方法）
    /// 清空或重置上次退出时间
    /// 下次再调用 secondsSinceLastExit() 就会返回 0
    func resetExitTime() {
        UserDefaults.standard.removeObject(forKey: lastExitKey)
        UserDefaults.standard.synchronize()
        print("🚮 已重置退出时间记录")
    }
}
