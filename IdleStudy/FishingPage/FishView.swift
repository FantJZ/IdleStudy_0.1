import SwiftUI

struct FishView: View {
    @EnvironmentObject var pondStore: PondStore
    @StateObject private var fishPresenter = FishPresenter()
    @State private var offlineSummary: String = ""
    
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
                                
                // 如果你要基于 pond.name 做鱼的计算，可在这里调用
                // 例如： let fishData = getFishForPond(pond.name)
                
                // 叠加你的前景视图
                ForegroundView()
                    .environmentObject(fishPresenter)
            } else {
                // 如果没有选中的池塘，就显示一个占位提示
                Text("尚未选择池塘")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
                    let result = fishPresenter.handleOfflineCatches()
                    if result.offlineSeconds > 0 {
                        // 计算小时、分钟、秒
                        let hours = result.offlineSeconds / 3600
                        let minutes = (result.offlineSeconds % 3600) / 60
                        let seconds = result.offlineSeconds % 60
                        
                        offlineSummary = """
                        你离开了 \(hours)小时\(minutes)分钟\(seconds)秒，
                        在这段时间里，共钓到：
                        鱼：\(result.fishCount) 条，
                        垃圾：\(result.garbageCount) 个，
                        宝藏：\(result.treasureCount) 个。
                        已全部放入背包！
                        """
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

