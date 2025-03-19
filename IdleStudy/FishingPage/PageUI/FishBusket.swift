import SwiftUI

// MARK: - 数据模型
struct Fish: Identifiable, Decodable {
    let id = UUID()
    let image: String
    let name: String
    let quality: String
    let weight: Double
    let price: Int
    let rarity: String
    
    // 兼容字典解码
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        image = try container.decode(String.self, forKey: .image)
        name = try container.decode(String.self, forKey: .name)
        quality = try container.decode(String.self, forKey: .quality)
        weight = try container.decode(Double.self, forKey: .weight)
        price = try container.decode(Int.self, forKey: .price)
        rarity = try container.decode(String.self, forKey: .rarity)
    }
    
    enum CodingKeys: String, CodingKey {
        case image, name, quality, weight, price, rarity
    }
}

// MARK: - 主视图
struct FishBusket: View {
    @State private var fishes: [Fish] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // 两列网格布局
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("加载中...")
            } else if let error = errorMessage {
                Text("错误: \(error)")
                    .foregroundColor(.red)
            } else if fishes.isEmpty {
                Text("鱼篓空空如也")
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(fishes) { fish in
                            FishCard(fish: fish)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("我的鱼篓")
        .onAppear(perform: loadFishData)
    }
    
    // MARK: - 数据加载
    private func loadFishData() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let dictArray = try FishBusketManager.shared.loadDictionary()
                
                // 转换为 Fish 数组
                let decodedFishes = try dictArray.compactMap { (key, value) -> Fish? in
                    guard let fishDict = value as? [String: Any] else { return nil }
                    let jsonData = try JSONSerialization.data(withJSONObject: fishDict)
                    return try JSONDecoder().decode(Fish.self, from: jsonData)
                }
                
                DispatchQueue.main.async {
                    self.fishes = decodedFishes
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - 鱼卡片组件
struct FishCard: View {
    let fish: Fish
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: fish.image)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(fish.name)
                    .font(.headline)
                
                HStack {
                    Text("品质")
                        .foregroundColor(.secondary)
                    Text(fish.quality)
                        .foregroundColor(qualityColor)
                }
                
                HStack {
                    Text("重量")
                        .foregroundColor(.secondary)
                    Text("\(fish.weight, specifier: "%.2f") kg")
                }
                
                HStack {
                    Text("价格")
                        .foregroundColor(.secondary)
                    Text("\(fish.price) 金币")
                }
                
                HStack {
                    Text("稀有度")
                        .foregroundColor(.secondary)
                    Text(fish.rarity)
                        .foregroundColor(rarityColor)
                }
            }
            .padding(.horizontal, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - 样式计算属性
    private var qualityColor: Color {
        switch fish.quality {
        case "普通": return .gray
        case "稀有": return .blue
        case "史诗": return .purple
        case "传说": return .orange
        default: return .primary
        }
    }
    
    private var rarityColor: Color {
        switch fish.rarity {
        case "常见": return .green
        case "稀有": return .blue
        case "SSR": return .purple
        case "UR": return .red
        default: return .primary
        }
    }
}

// MARK: - 预览
#Preview {
    NavigationStack {
        FishBusket()
    }
}
