import Foundation

class FishingShopManager: ObservableObject {
    static let shared = FishingShopManager()

    // 商店的分类标签
    enum ShopTab: String, CaseIterable, Codable {
        case cart = "购物车"
        case backpack = "背包"
        case rods = "钓竿"
    }

    @Published var selectedTab: ShopTab = .cart              // 当前选中的标签页
    @Published var storeItems: [ShopTab: [StoreItem]] = [:]  // 商店物品按分类存储
    @Published var cartItems: [StoreItem: Int] = [:]         // 购物车：物品及数量

    init() {
        loadStoreItemsFromJSON() // 初始化时加载商品数据
    }

    // 从 JSON 文件加载商品并映射到对应的分类
    func loadStoreItemsFromJSON() {
        guard let url = Bundle.main.url(forResource: "FishingShopItems", withExtension: "json") else {
            print("❌ 找不到 FishingShopItems.json")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let rawItems = try JSONDecoder().decode([StoreItemRaw].self, from: data)
            
            var itemsDict: [ShopTab: [StoreItem]] = [:]
            for raw in rawItems {
                guard let tab = ShopTab(rawValue: raw.tab) else {
                    print("⚠️ 无效的 tab: \(raw.tab)")
                    continue
                }
                let item = StoreItem(name: raw.name, image: raw.image, price: raw.price, description: raw.description)
                itemsDict[tab, default: []].append(item)
            }

            DispatchQueue.main.async {
                self.storeItems = itemsDict
            }
            print("✅ 成功加载商店物品")
        } catch {
            print("❌ 加载失败: \(error)")
        }
    }

    // 向购物车中添加物品
    func addToCart(item: StoreItem, quantity: Int) {
        cartItems[item, default: 0] += quantity
        if cartItems[item]! <= 0 {
            cartItems.removeValue(forKey: item)
        }
    }

    // 获取购物车总价格
    func totalCartPrice() -> Int {
        cartItems.reduce(0) { $0 + $1.key.price * $1.value }
    }

    // 购买全部物品（清空购物车）
    func buyAll() {
        cartItems.removeAll()
    }

    // 移除购物车内全部物品
    func removeAll() {
        cartItems.removeAll()
    }
}

// 商品对象：展示与购物使用
struct StoreItem: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let image: String
    let price: Int
    let description: String
}

// JSON 原始格式
struct StoreItemRaw: Codable {
    let tab: String
    let name: String
    let image: String
    let price: Int
    let description: String
}
