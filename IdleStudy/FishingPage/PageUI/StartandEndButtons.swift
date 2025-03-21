//
//  StartandEndButtons.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/16.
//

import SwiftUI

struct StartandEndButtons: View {
  @Binding var showSlideBar: Bool
  @Binding var startTiming: Bool
  @Binding var selectedTime: Double
  @State var isStartPressed: Bool = false // 控制弹出弹窗

  var body: some View {
    // 根据 startTiming 显示不同按钮
    if !self.startTiming {
      // ---- Start 按钮 ----
      Button(action: {
        // 点下后弹出弹窗，让用户选择时间
        self.startTiming = true
        self.showSlideBar = false
      }) {
        Text("Start")
          .foregroundColor(.white)
          .frame(width: 100, height: 75)
          .background(Color.blue)
          .cornerRadius(20)
          .font(.largeTitle)
      }
//            // 用 sheet 弹出时间选择器
//            .sheet(isPresented: $isStartPressed) {
//                TimeSelectorPopup(
//                    selectedTime: $selectedTime,
//                    startTiming: $startTiming
//                )
//            }
    } else {
      // ---- End 按钮 ----
      Button(action: {
        // 停止计时逻辑
          self.startTiming = false
          self.showSlideBar = true
          
          do {
              try FishBusketManager.shared.removeAllFishes()
              print("✅ 已清空文件中的鱼数据")
          } catch {
              print("❌ 清空失败: \(error)")
          }
      }) {
        Text("End")
          .foregroundColor(.white)
          .frame(width: 100, height: 75)
          .background(Color.red)
          .cornerRadius(20)
          .font(.largeTitle)
      }
    }
  }
}
