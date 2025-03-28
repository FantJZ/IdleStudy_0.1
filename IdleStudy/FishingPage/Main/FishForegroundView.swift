import SwiftUI

struct ForegroundView: View {
    @State var startTiming: Bool = false // 是否开始计时
    @State var showFishGuide: Bool = false
    @State var showSlideBar: Bool = true
    @State var showPlayerBackpack: Bool = false
    @State var showExperienceBar: Bool = false
    
    /// 局部变量
    @EnvironmentObject private var presenter: FishPresenter

    var body: some View {
        // 1. 在最外层使用 ZStack，并指定 alignment 为 center
        ZStack(alignment: .center) {
            
            // 2. 原有的 VStack，用于顶部栏、底部按钮等
            VStack(spacing: 20) {
                // 顶部栏
                topBarView(
                    startTiming: self.$startTiming,
                    showFishGuide: self.$showFishGuide,
                    showPlayerBackpack: self.$showPlayerBackpack
                )
                
                Spacer()
                
                // SlideBar / ExperienceBar
                if self.showSlideBar {
                    SlideBar(selectedTime: self.$presenter.selectedTime)
                } else {
                    ExperienceBarView(experienceManager: ExperienceManager())
                }
                
                // 底部按钮
                StartandEndButtons(
                    showSlideBar: self.$showSlideBar,
                    startTiming: self.$startTiming,
                    selectedTime: self.$presenter.selectedTime
                )
            }
            
            // 3. 如果需要显示鱼目录
            if self.showFishGuide {
                FishGuideView(showFishGuide: $showFishGuide)
            }
            
            // 4. 如果需要显示鱼篓
            if self.showPlayerBackpack {
                PlayerBackpackView(showPlayerBackpack: $showPlayerBackpack)
                    .padding()
                    .ignoresSafeArea()
            }
            
            // 5. 将 FishDataPopsOut 移到最外层的 ZStack 中
            //   并去掉内部的 Spacer，以便它可以位于正中央
            if self.presenter.isOneMinute {
                FishDataPopsOut()
                    .onAppear {
                        // 3 秒后自动隐藏
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.presenter.isOneMinute.toggle()
                        }
                    }
            }
        }
    }
}

// MARK: - 预览
#Preview {
    ForegroundView()
        .environmentObject(FishPresenter())
        .environmentObject(PondStore())

}
