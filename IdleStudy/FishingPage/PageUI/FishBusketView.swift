import SwiftUI

struct FishBusketView: View {
    @State private var fishes: [FishInFishBusket] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Binding var showFishBusket: Bool
    
    // 新增：用于记录当前的排序方式
    @State private var sortOption: SortOption = .priceDesc
    
    // 定义可用的排序方式
    enum SortOption {
        case name
        case rarity
        case quality
        case priceAsc
        case priceDesc
    }
    
    // 2 列布局示例
    private let columns = [
        GridItem(.flexible(minimum: 150), spacing: 16),
        GridItem(.flexible(minimum: 150), spacing: 16),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                            .ignoresSafeArea()

                // 主要内容视图
                contentView
            }
            .navigationTitle("🐟 我的鱼篓")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true) // 隐藏系统自带的返回按钮
            .toolbar {
                
                // 左侧：自定义返回按钮
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showFishBusket = false
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                }
                
                // 右侧：排序菜单
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("排序") {
                        Button("名称") {
                            sortOption = .name
                            applySort()
                        }
                        Button("稀有度") {
                            sortOption = .rarity
                            applySort()
                        }
                        Button("品质") {
                            sortOption = .quality
                            applySort()
                        }
                        Button("价格升序") {
                            sortOption = .priceAsc
                            applySort()
                        }
                        Button("价格降序") {
                            sortOption = .priceDesc
                            applySort()
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadFishData)
    }
    
    
    // MARK: - 主内容视图
    private var contentView: some View {
        Group {
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(error: error)
            } else if fishes.isEmpty {
                emptyView
            } else {
                fishGrid
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - 排序逻辑
extension FishBusketView {
    /// 根据当前 sortOption，对 fishes 数组进行排序
    private func applySort() {
        switch sortOption {
        case .name:
            // 按名称升序
            fishes.sort { $0.name < $1.name }
        case .rarity:
            // 按稀有度升序（根据字符串顺序）
            fishes.sort { $0.rarity < $1.rarity }
        case .quality:
            // 按品质升序（根据字符串顺序）
            fishes.sort { $0.quality < $1.quality }
        case .priceAsc:
            // 价格从低到高
            fishes.sort { $0.price < $1.price }
        case .priceDesc:
            // 价格从高到低
            fishes.sort { $0.price > $1.price }
        }
    }
}

// MARK: - 视图组件扩展
extension FishBusketView {
    // 加载中视图
    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            Text("正在加载鱼获...")
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // 错误提示视图
    private func errorView(error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            VStack(spacing: 6) {
                Text("加载失败")
                    .font(.headline)
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // 空状态视图
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "fish.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.3))
            
            VStack(spacing: 6) {
                Text("鱼篓空空如也")
                    .font(.headline)
                Text("快去钓第一条鱼吧！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // 鱼获网格视图
    private var fishGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(fishes) { fish in
                    FishCardView(fish: fish)
                        .transition(.opacity)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            loadFishData()
        }
    }
}

// MARK: - 数据加载逻辑
extension FishBusketView {
    private func loadFishData() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // 从文件读取所有鱼的字典
                let fishArray = try FishBusketManager.shared.loadFishArray()
                
                // 转换数据模型
                let decodedData = try fishArray.compactMap { fishDict -> FishInFishBusket? in
                    let jsonData = try JSONSerialization.data(withJSONObject: fishDict)
                    return try JSONDecoder().decode(FishInFishBusket.self, from: jsonData)
                }
                
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.fishes = decodedData
                        // 读取完后先按当前 sortOption 排序
                        self.applySort()
                        
                        self.isLoading = false
                    }
                }
            } catch let error as FishBusketManager.FileError {
                handleFileError(error)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "数据解析失败: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func handleFileError(_ error: FishBusketManager.FileError) {
        DispatchQueue.main.async {
            switch error {
            case .fileNotFound:
                self.errorMessage = "尚未保存任何鱼获"
                do {
                    // 自动创建空文件
                    try FishBusketManager.shared.saveDictionary([:])
                } catch {
                    self.errorMessage = "初始化鱼篓失败"
                }
            case .invalidPath:
                self.errorMessage = "存储路径不可用"
            case .decodingFailed:
                self.errorMessage = "数据格式错误"
            case .encodingFailed:
                self.errorMessage = "数据存储失败"
            case .migrationFailed:
                self.errorMessage = "数据迁移失败"
            }
            self.isLoading = false
        }
    }
}

// MARK: - 鱼卡片组件示例
struct FishCardView: View {
    let fish: FishInFishBusket
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            detailsSection
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
    
    // 头部区域（图片和名称）
    private var headerSection: some View {
        VStack(spacing: 10) {
            // 图片显示（支持本地和系统图标）
            Group {
                if let image = UIImage(named: fish.image) {
                    Image(uiImage: image)
                        .resizable()
                } else {
                    Image(systemName: fish.image)
                        .resizable()
                        .foregroundColor(.blue)
                }
            }
            .scaledToFit()
            .frame(height: isExpanded ? 120 : 80)
            .padding(.horizontal)
            
            // 名称和稀有度标签
            HStack {
                Text(fish.name)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                Text(fish.rarity)
                    .font(.caption)
                    .bold()
                    .padding(4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }
        }
    }
    
    // 详细信息区域
    @ViewBuilder
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            infoRow(label: "品质", value: fish.quality)
            infoRow(label: "重量", value: String(format: "%.2f", fish.weight), suffix: "kg")
            infoRow(label: "价格", value: "\(fish.price)", suffix: "金币")
            
            if isExpanded {
                Divider()
                Text("捕获时间: \(Date(), style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func infoRow(label: String, value: String, suffix: String? = nil) -> some View {
        HStack {
            Text("\(label):")
                .foregroundColor(.secondary)
            Text(value)
            if let suffix = suffix {
                Text(suffix).foregroundColor(.secondary)
            }
            Spacer()
        }
        .font(.subheadline)
    }
}

// MARK: - 预览
#Preview {
    FishBusketView(showFishBusket: .constant(true))
}

