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

        if self.remainingSeconds % 60 == 0 && self.remainingSeconds > 0 {
          print("定时器到了一分钟")
          self.isOneMinute = true
            FishGuideManager.shared.syncFromBusket()
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
}
