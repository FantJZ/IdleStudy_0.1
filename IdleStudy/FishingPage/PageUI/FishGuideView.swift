import SwiftUI

struct FishGuideView: View {
    // 是否处于管理员模式
    @State private var isAdminMode: Bool = false
    // 图鉴数据
    @State private var guideEntries: [FishGuideEntry] = []
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var showFishGuide: Bool
    
    // 自定义稀有度顺序
    private let rarityOrder: [String] = ["至臻", "传说", "史诗", "稀有", "普通"]
    
    var body: some View {
        NavigationStack {
            List {
                // 按 pond 分组
                let pondGroups = Dictionary(grouping: guideEntries, by: \.pond)
                
                ForEach(pondGroups.keys.sorted(), id: \.self) { pondName in
                    Section {
                        ForEach(rarityOrder, id: \.self) { r in
                            let fishesOfThisRarity = pondGroups[pondName]?.filter { $0.rarity == r } ?? []
                            if !fishesOfThisRarity.isEmpty {
                                Text(r)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                                
                                ForEach(fishesOfThisRarity) { entry in
                                    NavigationLink {
                                        // 详情页面
                                        FishGuideDetailView(entry: entry)
                                    } label: {
                                        FishGuideRow(entry: entry)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text(pondName)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("鱼类图鉴")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("更多") {
                        Toggle("管理员模式", isOn: $isAdminMode)
                        if isAdminMode {
                            // 清空图鉴
                            Button(role: .destructive) {
                                FishGuideManager.shared.clearGuide()
                                refreshData()
                            } label: {
                                Text("清空图鉴")
                            }
                            // 解锁所有鱼
                            Button("解锁所有鱼") {
                                FishGuideManager.shared.unlockAllFishes()
                                refreshData()
                            }
                            // 为所有鱼添加炫彩
                            Button("添加炫彩") {
                                FishGuideManager.shared.setAllRainbow()
                                refreshData()
                            }
                            // 设置所有鱼钓到总数量
                            Button("总数=100") {
                                FishGuideManager.shared.setAllCaughtCount(to: 100)
                                refreshData()
                            }
                            Button("总数=500") {
                                FishGuideManager.shared.setAllCaughtCount(to: 500)
                                refreshData()
                            }
                            Button("总数=1000") {
                                FishGuideManager.shared.setAllCaughtCount(to: 1000)
                                refreshData()
                            }
                            Button("总数=10000") {
                                FishGuideManager.shared.setAllCaughtCount(to: 10000)
                                refreshData()
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showFishGuide = false
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                refreshData()
            }
        }
    }
    
    private func refreshData() {
        FishGuideManager.shared.adminMode = isAdminMode
        guideEntries = FishGuideManager.shared.guideEntries
    }
}

/// 列表行视图：
/// - 行背景根据 caughtCount 显示颜色；
/// - 若钓到最大可能体重，只在“图片区域”静态半透明炫彩覆盖。
struct FishGuideRow: View {
    let entry: FishGuideEntry
    
    /// 是否钓到最大可能体重
    private var hasMaxWeight: Bool {
        (entry.caughtMaxWeight ?? 0) >= entry.maxWeightPossible - 0.00001
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 图片 + (可能的炫彩)
            ZStack {
                // 显示鱼图或黑方块
                if entry.discovered {
                    if let img = UIImage(named: entry.image) {
                        Image(uiImage: img)
                            .resizable()
                            .interpolation(.none)
                            .antialiased(false)
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else {
                        Image(systemName: entry.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                } else {
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                }
                
                // 若已达成最大体重，则在图片上叠加半透明彩虹
                if hasMaxWeight {
                    LinearGradient(
                        gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                    .opacity(0.5)
                    .frame(width: 40, height: 40)
                }
            }
            
            // 文字信息
            if entry.discovered {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.name)
                    Text("钓到次数：\(entry.caughtCount)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("???")
            }
            
            Spacer()
        }
        .padding(6)
        .background(rowBackground)
        .cornerRadius(8)
    }
    
    /// 行背景：根据 caughtCount 显示颜色
    @ViewBuilder
    private var rowBackground: some View {
        if !entry.discovered {
            Color.clear
        } else {
            switch entry.caughtCount {
            case 10000...:
                Color.red.opacity(0.3)
            case 1000...:
                Color.yellow.opacity(0.3)
            case 500...:
                Color.purple.opacity(0.3)
            case 100...:
                Color.blue.opacity(0.3)
            default:
                Color.clear
            }
        }
    }
}

/// 图鉴详情页保持不变
struct FishGuideDetailView: View {
    let entry: FishGuideEntry
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if !entry.discovered {
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(width: 100, height: 100)
                    Text("???")
                        .font(.title)
                } else {
                    if let img = UIImage(named: entry.image) {
                        Image(uiImage: img)
                            .resizable()
                            .interpolation(.none)
                            .antialiased(false)
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    } else {
                        Image(systemName: entry.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    Text(entry.name)
                        .font(.title)
                }
                
                infoSection
            }
            .padding()
            .background(backgroundView)
            .navigationTitle("图鉴详情")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var infoSection: some View {
        if !entry.discovered {
            Text("尚未发现此鱼")
                .foregroundColor(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("稀有度：\(entry.rarity)")
                Text("最大体重（可能）：\(entry.maxWeightPossible, specifier: "%.2f") kg")
                Text("最小体重（可能）：\(entry.minWeightPossible, specifier: "%.2f") kg")
                
                if let caughtMin = entry.caughtMinWeight {
                    Text("玩家钓到的最小体重：\(caughtMin, specifier: "%.2f") kg")
                } else {
                    Text("玩家钓到的最小体重：暂无")
                }
                
                if let caughtMax = entry.caughtMaxWeight {
                    Text("玩家钓到的最大体重：\(caughtMax, specifier: "%.2f") kg")
                } else {
                    Text("玩家钓到的最大体重：暂无")
                }
                
                Text("已钓数量：\(entry.caughtCount)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var backgroundView: some View {
        if !entry.discovered {
            return AnyView(Color(.systemBackground))
        }
        
        let caughtMin = entry.caughtMinWeight ?? Double.greatestFiniteMagnitude
        let caughtMax = entry.caughtMaxWeight ?? 0.0
        let hasMin = abs(caughtMin - entry.minWeightPossible) < 0.0001
        let hasMax = abs(caughtMax - entry.maxWeightPossible) < 0.0001
        
        if hasMin && hasMax {
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .blue, .green, .yellow, .orange, .red]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else if hasMax {
            return AnyView(Color.yellow.opacity(0.3))
        } else {
            return AnyView(Color(.systemBackground))
        }
    }
}

// MARK: - 预览
#Preview {
    FishGuideView(showFishGuide: .constant(true))
}

