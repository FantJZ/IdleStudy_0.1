//
//  FishPresenter.swift
//  IdleStudy
//
//  Created by 大大 on 2025/3/19.
//

import Combine
import Foundation
import SwiftUI

class FishPresenter: ObservableObject {
  @Published var selectedTime: Double = 0 // 初始分钟数
  @Published var isOneMinute: Bool = false // 是否到达一分钟
  @Published private var remainingSeconds: Int = 0
    @Published var timeIntervalTriggerd: Int = 4 //多少秒钓一次鱼
    

  private var timerCancellable: Cancellable?
  private static let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  init() {
    _ = FishCache.shared
  }
  
  var timeString: String {
    let hours = self.remainingSeconds / 3600
    let minutes = (remainingSeconds % 3600) / 60
    let seconds = self.remainingSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
  }

  func startTimer() {
    self.stopTimer()
    self.remainingSeconds = Int(self.selectedTime * 60)

    self.timerCancellable = FishPresenter.timerPublisher.sink { [weak self] _ in
      guard let self = self else {
        return
      }
      if self.remainingSeconds > 0 {

          self.remainingSeconds -= 1
          print("定时操作: \(self.remainingSeconds)")

          if self.remainingSeconds % self.timeIntervalTriggerd == 0 && self.remainingSeconds > 0 {
          print("定时器到了一分钟")
          self.isOneMinute = true
        }
      } else {
        self.stopTimer()
        print("倒计时结束")
      }
    }
  }

  func stopTimer() {
    self.timerCancellable?.cancel()
    self.timerCancellable = nil
  }

  func resetTimer(minutes: Double) {
      self.selectedTime = minutes
      self.startTimer()
  }
    
    func subtractOfflineTime() {
            let offlineSec = BackgroundTimeManager.shared.secondsSinceLastExit()
            if offlineSec > 0 {
                self.remainingSeconds = max(self.remainingSeconds - offlineSec, 0)
                print("已扣除离开时长：\(offlineSec) 秒，剩余：\(self.remainingSeconds)")
                BackgroundTimeManager.shared.resetExitTime()
            }
        }
}

extension FishPresenter {
    /// 根据离开时长批量钓鱼，将得到的物品加入背包，返回钓到的统计信息
    func handleOfflineCatches() -> (fishCount: Int, garbageCount: Int, treasureCount: Int, offlineSeconds: Int) {
        
        // 1. 计算离开秒数
        let offlineSeconds = BackgroundTimeManager.shared.secondsSinceLastExit()
        guard offlineSeconds > 0 else {
            // 如果没有离开过或离开时间是 0，直接返回
            return (0, 0, 0, 0)
        }
        
        // 2. 根据 timeIntervalTriggerd 计算可钓次数
        let times = offlineSeconds / self.timeIntervalTriggerd
        if times <= 0 {
            // 离开时间不足一个间隔，不进行任何钓鱼
            return (0, 0, 0, offlineSeconds)
        }
        
        var fishCount = 0
        var garbageCount = 0
        var treasureCount = 0
        
        // 3. 循环触发钓鱼
        for _ in 0..<times {
            if let result = FishingManager.shared.getRandomCatch() {
                switch result {
                case .fish(let info):
                    // 加经验、同步图鉴、更新数据
                    ExperienceManager.shared.addXP(info.exp)
                    FishGuideManager.shared.syncFromBusket()
                    FishDataManager.shared.updateFishInfo(info)
                    
                    // 加入背包（FishBusketManager + PlayerBackpackManager）
                    let newFish = FishInFishBusket(
                        image: info.image,
                        name: info.fishName,
                        quality: info.quality,
                        weight: info.weight,
                        price: info.price,
                        rarity: info.rarity,
                        exp: info.exp
                    )
                    FishBusketManager.shared.allFishes.append(newFish)
                    FishBusketManager.shared.saveFishes()
                    PlayerBackpackManager.shared.fishBusketItems.append(newFish)
                    
                    fishCount += 1
                    
                case .garbage(let info):
                    let newGarbage = BackpackGarbageItem(
                        name: info.garbageName,
                        price: info.price,
                        pond: "未知",
                        description: info.description,
                        quantity: 1,
                        totalCount: 1,
                        fishedCount: 1,
                        image: info.image
                    )
                    PlayerBackpackManager.shared.addGarbageItem(newGarbage)
                    
                    garbageCount += 1
                    
                case .treasure(let info):
                    ExperienceManager.shared.addXP(info.exp)
                    let newTreasure = BackpackTreasureItem(
                        name: info.treasureName,
                        price: info.price,
                        pond: info.pond,
                        rarity: info.rarity,
                        exp: info.exp,
                        description: info.description,
                        quantity: 1,
                        totalCount: 1,
                        fishedCount: 1
                    )
                    PlayerBackpackManager.shared.addTreasureItem(newTreasure)
                    
                    treasureCount += 1
                }
            }
        }
        
        // 4. 重置退出时间，避免下次重复计算
        BackgroundTimeManager.shared.resetExitTime()
        
        return (fishCount, garbageCount, treasureCount, offlineSeconds)
    }
}

