//
//  IdleStudyApp.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/16.
//

import SwiftUI

@main
struct IdleStudyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    // 全局持有一个 PondStore，防止切换视图时被销毁
    @StateObject var pondStore = PondStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pondStore)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background, .inactive:
                // 1. 保存背包数据
                PlayerBackpackManager.shared.saveData()
//                // 2. 保存 PondStore
//                pondStore.saveData()
                // 3. 记录退出时间
                BackgroundTimeManager.shared.recordExitTime()
                
            case .active:
                // 从后台回到前台时，计算“退出到现在”的秒数
                let elapsedSeconds = BackgroundTimeManager.shared.secondsSinceLastExit()
                if elapsedSeconds > 0 {
                    print("本次离开时长：\(elapsedSeconds) 秒")
                    
                    // 这里可以做“离线收益”或其它逻辑
                    // 例如：根据 elapsedSeconds 给玩家发放奖励
                    // ...
                }
                
            default:
                break
            }
        }
    }
}
