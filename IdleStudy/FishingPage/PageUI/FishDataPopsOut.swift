//import SwiftUI
//
//struct FishDataPopsOut: View {
//    var body: some View {
//        ZStack {
//            // 背景卡片
//            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                // 使用线性渐变填充
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(colors: [
//                            Color.blue.opacity(0.4),
//                            Color.purple.opacity(0.4)
//                        ]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                // 在边缘再加一层白色描边
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20, style: .continuous)
//                        .stroke(Color.white.opacity(0.7), lineWidth: 2)
//                )
//                // 加一点阴影
//                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
//            
//            // 叠加的鱼信息视图
//            // 可以在这里或 FishInfoView 内部添加 padding、字体、颜色等定制
//            FishInfoView()
//                .padding()
//        }
//        // 调整卡片整体尺寸
//        .frame(width: 240, height: 340)
//        // 放置在屏幕中间略靠上
//        .position(
//            x: UIScreen.main.bounds.midX,
//            y: UIScreen.main.bounds.midY - 40
//        )
//    }
//}
//
//#Preview {
//    FishDataPopsOut()
//}
//
