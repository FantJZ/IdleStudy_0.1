import SwiftUI

/// 背包管理器，负责存储和管理背包数据与方法
class PlayerBackpackManager: ObservableObject {
    static let shared = PlayerBackpackManager()
    
    private init() {
        loadData()
    }
    
    // MARK: - 持久化相关（示例：垃圾和宝藏）
    private let garbageFileName = "garbageItems.json"
    private let treasureFileName = "treasureItems.json"
    
    // 如果需要也持久化鱼篓和鱼库，可另外定义 fishBusketFileName、fishLibraryFileName
    
    /// 将垃圾和宝藏数据分别写入文件
    func saveData() {
        do {
            let garbageURL = try fileURL(for: garbageFileName)
            let treasureURL = try fileURL(for: treasureFileName)
            
            // 将垃圾数组序列化
            let garbageData = try JSONEncoder().encode(garbageItems)
            try garbageData.write(to: garbageURL, options: .atomicWrite)
            
            // 将宝藏数组序列化
            let treasureData = try JSONEncoder().encode(treasureItems)
            try treasureData.write(to: treasureURL, options: .atomicWrite)
            
            print("✅ 背包数据已保存到文件（垃圾 & 宝藏）")
            
            // 如果要同时保存鱼篓和鱼库，也可在这里写入相应文件
            // saveFishBusketData()
            // saveFishLibraryData()
            
        } catch {
            print("❌ 保存背包数据失败：\(error)")
        }
    }
    
    /// 在初始化时从文件中加载垃圾和宝藏数据
    func loadData() {
        do {
            let garbageURL = try fileURL(for: garbageFileName)
            let treasureURL = try fileURL(for: treasureFileName)
            
            if FileManager.default.fileExists(atPath: garbageURL.path) {
                let gData = try Data(contentsOf: garbageURL)
                let gItems = try JSONDecoder().decode([BackpackGarbageItem].self, from: gData)
                self.garbageItems = gItems
            }
            
            if FileManager.default.fileExists(atPath: treasureURL.path) {
                let tData = try Data(contentsOf: treasureURL)
                let tItems = try JSONDecoder().decode([BackpackTreasureItem].self, from: tData)
                self.treasureItems = tItems
            }
            
            print("✅ 已从文件加载背包数据（垃圾 & 宝藏）")
            
            // 同理也可加载鱼篓和鱼库
            // loadFishBusketData()
            // loadFishLibraryData()
            
        } catch {
            print("❌ 加载背包数据失败：\(error)")
        }
    }
    
    /// 获取应用沙盒中合适的存储路径
    private func fileURL(for fileName: String) throws -> URL {
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            throw NSError(domain: "PlayerBackpackManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法访问 Document 目录"])
        }
        return documentsDir.appendingPathComponent(fileName)
    }
    
    enum BackpackTab: String, CaseIterable {
            case equipment    = "装备"
            case garbage      = "垃圾"
            case treasure     = "宝藏"
            case fishbusket   = "鱼篓"
            case fishlibrary  = "鱼库"
        }
        
        @Published var selectedTab: BackpackTab = .equipment
        
        // MARK: - 垃圾配置
        @Published var garbageRows: Int = 3
        @Published var garbageCols: Int = 4
        @Published var garbageStackLimit: Int = 8  // 垃圾最大堆叠数量
        
        // MARK: - 宝藏配置
        @Published var treasureRows: Int = 3
        @Published var treasureCols: Int = 4
        @Published var treasureStackLimit: Int = 8 // 宝藏最大堆叠数量
        
        // MARK: - 鱼篓配置
        @Published var fishBusketCols: Int = 4
        
        // MARK: - 鱼库配置
        @Published var fishLibraryRows: Int = 3
        @Published var fishLibraryCols: Int = 4
        
        // MARK: - 数据源：垃圾 & 宝藏
        @Published var garbageItems: [BackpackGarbageItem] = []
        @Published var treasureItems: [BackpackTreasureItem] = []
        
        // MARK: - 数据源：鱼篓 & 鱼库
        @Published var fishBusketItems: [FishInFishBusket] = []
        @Published var fishLibraryItems: [FishInFishBusket] = []
        
        // MARK: - 计算总价值
        func totalGarbageValue() -> Int {
            garbageItems.reduce(0) { $0 + $1.price * $1.quantity }
        }
        func totalTreasureValue() -> Int {
            treasureItems.reduce(0) { $0 + $1.price * $1.quantity }
        }
        func totalFishBusketValue() -> Int {
            fishBusketItems.reduce(0) { $0 + $1.price }
        }
        func totalFishLibraryValue() -> Int {
            fishLibraryItems.reduce(0) { $0 + $1.price }
        }
        
        // MARK: - 排序（省略）
        /// 垃圾的可选排序：按名称 / 价格 / 数量
        enum GarbageSortOption {
            case name, price, quantity
        }
        
        /// 宝藏的可选排序：按名称 / 价格 / 稀有度 / 数量
        enum TreasureSortOption {
            case name, price, rarity, quantity
        }
        
        // MARK: - 排序方法
        
        /// 对垃圾进行排序
        func sortGarbage(by option: GarbageSortOption) {
            switch option {
            case .name:
                garbageItems.sort { $0.name < $1.name }
            case .price:
                garbageItems.sort { $0.price < $1.price }
            case .quantity:
                garbageItems.sort { $0.quantity < $1.quantity }
            }
        }
        
        /// 对宝藏进行排序
        func sortTreasure(by option: TreasureSortOption) {
            switch option {
            case .name:
                treasureItems.sort { $0.name < $1.name }
            case .price:
                treasureItems.sort { $0.price < $1.price }
            case .rarity:
                treasureItems.sort { $0.rarity < $1.rarity }
            case .quantity:
                treasureItems.sort { $0.quantity < $1.quantity }
            }
        }

        // MARK: - 售卖全部（占位）
        func sellAllGarbage() { /* TODO */ }
        func sellAllTreasure() { /* TODO */ }
        func sellAllFishBusket() {
            fishBusketItems.removeAll()
        }
        
        // MARK: - 堆叠逻辑：添加垃圾
        /// 将新的垃圾物品堆叠到已有格子中；若都满则新开格子
        func addGarbageItem(_ newItem: BackpackGarbageItem) {
            // 剩余要添加的数量
            var remain = newItem.quantity
            
            while remain > 0 {
                // 1. 查找是否存在“同名且尚未满堆叠上限”的垃圾
                if let index = garbageItems.firstIndex(where: {
                    $0.name == newItem.name && $0.quantity < garbageStackLimit
                }) {
                    let capacity = garbageStackLimit - garbageItems[index].quantity
                    // 可填充多少
                    let used = min(remain, capacity)
                    
                    // 增加该格子的数量
                    garbageItems[index].quantity += used
                    // totalCount、fishedCount 也做相应增量（如需要）
                    garbageItems[index].totalCount += used
                    garbageItems[index].fishedCount += used
                    
                    remain -= used
                } else {
                    // 2. 没有同名格子可用，或都已满 → 新开一个格子
                    var item = newItem
                    item.quantity = min(remain, garbageStackLimit)
                    item.totalCount = item.quantity
                    item.fishedCount = item.quantity
                    remain -= item.quantity
                    
                    garbageItems.append(item)
                }
            }
        }
        
        // MARK: - 堆叠逻辑：添加宝藏
        func addTreasureItem(_ newItem: BackpackTreasureItem) {
            var remain = newItem.quantity
            
            while remain > 0 {
                if let index = treasureItems.firstIndex(where: {
                    $0.name == newItem.name && $0.quantity < treasureStackLimit
                }) {
                    let capacity = treasureStackLimit - treasureItems[index].quantity
                    let used = min(remain, capacity)
                    
                    treasureItems[index].quantity += used
                    treasureItems[index].totalCount += used
                    treasureItems[index].fishedCount += used
                    
                    remain -= used
                } else {
                    var item = newItem
                    item.quantity = min(remain, treasureStackLimit)
                    item.totalCount = item.quantity
                    item.fishedCount = item.quantity
                    remain -= item.quantity
                    
                    treasureItems.append(item)
                }
            }
        }
        
        // MARK: - 将鱼从鱼篓移到鱼库（鱼不堆叠，故直接移动）
        func moveFishToLibrary(_ fish: FishInFishBusket) {
            if let index = fishBusketItems.firstIndex(where: { $0.id == fish.id }) {
                fishBusketItems.remove(at: index)
            }
            fishLibraryItems.append(fish)
        }
}
