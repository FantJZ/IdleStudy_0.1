//
//  TopBar.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/16.
//

import SwiftUI

// MARK: - 顶部栏

struct topBarView: View {
    @Environment(\.dismiss) var dismiss
  @Binding var startTiming: Bool
  @Binding var showFishGuide: Bool
  @Binding var showPlayerBackpack: Bool

  var body: some View {
    VStack {
      HStack {
        // Back/Close 按钮
        Button(action: {
            dismiss()
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
            self.showPlayerBackpack = true
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
    .padding()
  }
}
#Preview {
    topBarView(startTiming: .constant(false), showFishGuide: .constant(true), showPlayerBackpack: .constant(true))
}
