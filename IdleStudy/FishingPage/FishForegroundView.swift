//
//  FishForegroundView.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/16.
//

import SwiftUI

struct ForegroundView: View {
  @State var startTiming: Bool = false // 是否开始计时
  @State var showListFishes: Bool = false
  @State var showSlideBar: Bool = true

  /// 局部变量
  @EnvironmentObject private var presenter: FishPresenter

  var body: some View {
    ZStack {
      VStack {
        // 顶部栏
        topBarView(
          startTiming: self.$startTiming,
          showListFishes: self.$showListFishes
        )

        Spacer()
        if self.presenter.isOneMinute {
          FishDataPopsOut()
            .onAppear {
              DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.presenter.isOneMinute.toggle()
              }
            }
        }

        Spacer()

        if self.showSlideBar == true {
          SlideBar(selectedTime: self.$presenter.selectedTime)
        }
        // 底部按钮
        StartandEndButtons(
          showSlideBar: self.$showSlideBar,
          startTiming: self.$startTiming,
          selectedTime: self.$presenter.selectedTime
        )
      }

      // 显示鱼的目录
      if self.showListFishes == true {
        FishListsView(showListFishes: self.$showListFishes)
      }
    }
  }
}
//测试

#Preview {
  ForegroundView()
}
