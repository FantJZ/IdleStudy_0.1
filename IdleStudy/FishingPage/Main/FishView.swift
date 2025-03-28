import SwiftUI

struct FishView: View {
    @EnvironmentObject var pondStore: PondStore
    @StateObject private var fishPresenter = FishPresenter()
    
    // 用于存储离线提示文本
    @State private var offlineSummary: String = ""
    // 用于控制是否显示离线提示
    @State private var showOfflineSummary: Bool = false
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            if let pond = pondStore.selectedPond {
                // 用 pond.imageName 显示背景
                Image(pond.imageName)
                    .resizable()
                    .interpolation(.none)
                    .antialiased(false)
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // 叠加你的前景视图
                ForegroundView()
                    .environmentObject(fishPresenter)
                
                // 如果 showOfflineSummary 为 true，就显示离线提示
                if showOfflineSummary {
                    // 一个带背景板的提示视图
                    VStack {
                        Text(offlineSummary)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .padding()
                    .transition(.opacity)  // 可以加一些动画
                }
            } else {
                // 如果没有选中的池塘，就显示一个占位提示
                Text("尚未选择池塘")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                handleOffline()
            }
        }
    }
    private func handleOffline() {
        let result = fishPresenter.handleOfflineCatches()
        if result.offlineSeconds > 0 {
            // 计算小时、分钟、秒
            let hours = result.offlineSeconds / 3600
            let minutes = (result.offlineSeconds % 3600) / 60
            let seconds = result.offlineSeconds % 60
            
            offlineSummary = """
            你离开了 \(hours)小时\(minutes)分钟\(seconds)秒，
            共钓到：鱼\(result.fishCount)、垃圾\(result.garbageCount)、宝藏\(result.treasureCount)
            已全部放入背包！
            """
            self.showOfflineSummary = true
            if self.showOfflineSummary == true {
                print("已经显示离线数据")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.showOfflineSummary = false
                }
            }
        }
    }
}

#Preview {
    // 构造一个 store，并设置一个池塘用于预览
    let store = PondStore()
//    store.selectedPond = Pond(name: "测试池塘",
//                              description: "用于预览的简介",
//                              imageName: "Background_neighborsPond")
    
    return FishView()
        .environmentObject(store)
}

