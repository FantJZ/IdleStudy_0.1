import SwiftUI

/// 池塘模型：演示用，包含“名称”与“图片名称”
struct Pond: Identifiable {
    let id = UUID()
    let name: String          // 池塘名称
    let description: String   // 池塘简介
    let imageName: String     // 用于卡片背景或其他用途
}

/// 数据中心：存储当前选中的池塘，让所有子视图都能读取
class PondStore: ObservableObject {
    /// 用户当前选中的池塘（可能为空）
    @Published var selectedPond: Pond?
}

// MARK: - 单个卡片视图
struct PondCardView: View {
    let pond: Pond
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 背景图片
            Image(pond.imageName)
                .resizable()
                .interpolation(.none)
                .antialiased(false)
                .scaledToFill()
                .frame(height: 220)
                .clipped()
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
            
            // 底部渐变蒙层，保证文字清晰
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.6)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(16)
            
            // 文本信息：池塘名称 + 简介
            VStack(alignment: .leading, spacing: 6) {
                Text(pond.name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Text(pond.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            .padding()
        }
        .frame(height: 220)
        .padding(.horizontal)
        .contentShape(Rectangle()) // 确保整个卡片区域都可点击
    }
}

// MARK: - 池塘选择视图
struct PondSelectionView: View {
    @EnvironmentObject var pondStore: PondStore
    
    // 示例数据：可替换为你的真实池塘信息
    let ponds: [Pond] = [
        Pond(name: "邻居家的池塘",
             description: "谁知道你邻居家池塘里都有些什么",
             imageName: "Background_neighborsPond"),
        Pond(name: "山涧溪流",
             description: "清澈见底的山涧溪水，盛产山泉鱼。",
             imageName: "pond_mountain"),
        Pond(name: "湖泊水域",
             description: "广阔的湖泊，拥有丰富多样的鱼类。",
             imageName: "pond_lake"),
        Pond(name: "海边礁岩",
             description: "靠近海岸的礁岩池塘，可捕到稀有海鱼。",
             imageName: "pond_seaside"),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // 标题
                    Text("选择池塘")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 20)
                    
                    // 卡片列表
                    ForEach(ponds) { pond in
                        NavigationLink {
                            // 在跳转时，把 selectedPond 设置为当前 pond
                            FishView()
                                .onAppear {
                                    pondStore.selectedPond = pond
                                    FishCache.shared.pondStore = pondStore
                                }
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            PondCardView(pond: pond)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 预览
#Preview {
    // 构造一个 store 注入环境，测试预览
    PondSelectionView()
        .environmentObject(PondStore())
}
