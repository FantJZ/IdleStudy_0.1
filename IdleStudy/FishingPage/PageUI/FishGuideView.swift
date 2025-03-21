import SwiftUI

struct FishGuideView: View {
    // 是否处于管理员模式（决定是否显示“清空图鉴”按钮）
    @State private var isAdminMode: Bool = false
    
    // 从 Manager 获取所有图鉴数据
    @State private var guideEntries: [FishGuideEntry] = []
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var showFishGuide: Bool
    
    // 自定义稀有度的显示顺序（从最稀有到最普通）
    private let rarityOrder: [String] = ["至臻", "传说", "史诗", "稀有", "普通"]
    
    var body: some View {
        NavigationStack {
            List {
                // 先按 pond 分组
                let pondGroups = Dictionary(grouping: guideEntries, by: \.pond)
                
                // 对每个池塘创建一个 Section
                ForEach(pondGroups.keys.sorted(), id: \.self) { pondName in
                    Section {
                        // 在该池塘下，按照自定义顺序列出每种稀有度
                        ForEach(rarityOrder, id: \.self) { r in
                            // 找出该池塘里、该稀有度的所有鱼
                            let fishesOfThisRarity = pondGroups[pondName]?.filter { $0.rarity == r } ?? []
                            
                            // 如果这个稀有度下没有鱼，就跳过
                            if !fishesOfThisRarity.isEmpty {
                                // 副标题：稀有度
                                Text(r)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                                
                                // 显示这些鱼
                                ForEach(fishesOfThisRarity) { entry in
                                    NavigationLink {
                                        // 点击进入详情页面
                                        FishGuideDetailView(entry: entry)
                                    } label: {
                                        FishGuideRow(entry: entry)
                                    }
                                }
                            }
                        }
                    } header: {
                        // 池塘名称作为 Section 的标题
                        Text(pondName)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("鱼类图鉴")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("更多") {
                        // 切换管理员模式
                        Toggle("管理员模式", isOn: $isAdminMode)
                        
                        // 只有在管理员模式时，才显示“清空图鉴”按钮
                        if isAdminMode {
                            Button(role: .destructive) {
                                FishGuideManager.shared.clearGuide()
                                refreshData()
                            } label: {
                                Text("清空图鉴")
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
                guideEntries = FishGuideManager.shared.guideEntries
            }
        }
    }
    
    /// 刷新数据：从 Manager 拉取最新的图鉴
    private func refreshData() {
        // 同步 adminMode
        FishGuideManager.shared.adminMode = isAdminMode
        
        // 拉取所有图鉴信息
        guideEntries = FishGuideManager.shared.guideEntries
    }
}

/// 图鉴的行视图：如果未发现，显示黑图 & ???；已发现则显示真名 & 图片
struct FishGuideRow: View {
    let entry: FishGuideEntry
    
    var body: some View {
        HStack(spacing: 12) {
            if entry.discovered {
                // 显示真实图片
                if let img = UIImage(named: entry.image) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                } else {
                    Image(systemName: entry.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                
                Text(entry.name)
            } else {
                // 未发现：显示黑色占位图 & ??? 名称
                Rectangle()
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                Text("???")
            }
        }
    }
}

/// 图鉴的详情页面
struct FishGuideDetailView: View {
    let entry: FishGuideEntry
    
    var body: some View {
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

#Preview{
    FishGuideView(showFishGuide: .constant(true))
}
