//
//  TopBar.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/16.
//

import SwiftUI

// MARK: - 顶部栏

struct topBarView: View {
  @Binding var startTiming: Bool
  @Binding var showFishGuide: Bool
  @Binding var showFishBusket: Bool

  var body: some View {
    VStack {
      HStack {
        // Back/Close 按钮
        Button(action: {
          // ...
        }) {
          Image(systemName: "xmark")
            .foregroundColor(.black)
        }
        .padding(.leading)
        Spacer()
        
        Button(action: {
          self.showFishGuide = true
        }) {
          Image(systemName: "book.pages")
            .foregroundColor(.black)
        }
        .padding(.trailing)
        
        Button(action: {
          self.showFishBusket = true
        }) {
          Image(systemName: "backpack")
            .foregroundColor(.black)
        }
        .padding(.trailing)
      }
      

      // 当开始计时后，显示正向 & 倒计时
      if self.startTiming {
        VStack {
          FishTimerView()
        }
        .padding(.all, 10)
        .background(Color.blue)
        .cornerRadius(10)
      }
    }
  }
}
#Preview {
  topBarView(startTiming: .constant(false), showFishGuide: .constant(true), showFishBusket: .constant(true))
}
