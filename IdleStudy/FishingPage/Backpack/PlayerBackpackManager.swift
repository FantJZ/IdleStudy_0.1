import SwiftUI

/// 背包管理器，负责存储和管理背包数据与方法
class PlayerBackpackManager: ObservableObject {
    static let shared = PlayerBackpackManager()
    
    private init() {
        loadData()
    }
    
    // MARK: - 文件名
    private let garbageFileName = "garbageItems.json"
    private let treasureFileName = "treasureItems.json"
    private let fishBusketFileName = "fishBusketItems.json"
    private let fishLibraryFileName = "fishLibraryItems.json"
    
    // MARK: - 数据源
    @Published var garbageItems: [BackpackGarbageItem] = []
    @Published var treasureItems: [BackpackTreasureItem] = []
    @Published var fishBusketItems: [FishInFishBusket] = []
    @Published var fishLibraryItems: [FishInFishBusket] = []
    
    // MARK: - 其余配置
    enum BackpackTab: String, CaseIterable {
        case equipment    = "装备"
        case garbage      = "垃圾"
        case treasure     = "宝藏"
        case fishbusket   = "鱼篓"
        case fishlibrary  = "鱼库"
    }
    @Published var selectedTab: BackpackTab = .equipment
    
    @Published var garbageRows: Int = 3
    @Published var garbageCols: Int = 4
    @Published var garbageStackLimit: Int = 8
    
    @Published var treasureRows: Int = 3
    @Published var treasureCols: Int = 4
    @Published var treasureStackLimit: Int = 8
    
    @Published var fishBusketCols: Int = 4
    @Published var fishLibraryRows: Int = 3
    @Published var fishLibraryCols: Int = 4
    
    // MARK: - 保存所有数据
    func saveData() {
        do {
            // 1) 保存垃圾
            let garbageURL = try fileURL(for: garbageFileName)
            let garbageData = try JSONEncoder().encode(garbageItems)
            try garbageData.write(to: garbageURL, options: .atomicWrite)
            
            // 2) 保存宝藏
            let treasureURL = try fileURL(for: treasureFileName)
            let treasureData = try JSONEncoder().encode(treasureItems)
            try treasureData.write(to: treasureURL, options: .atomicWrite)
            
            // 3) 保存鱼篓
            let fishBusketURL = try fileURL(for: fishBusketFileName)
            let fishBusketData = try JSONEncoder().encode(fishBusketItems)
            try fishBusketData.write(to: fishBusketURL, options: .atomicWrite)
            
            // 4) 保存鱼库
            let fishLibraryURL = try fileURL(for: fishLibraryFileName)
            let fishLibraryData = try JSONEncoder().encode(fishLibraryItems)
            try fishLibraryData.write(to: fishLibraryURL, options: .atomicWrite)
            
            print("✅ 已保存背包数据（垃圾、宝藏、鱼篓、鱼库）到文件")
        } catch {
            print("❌ 保存背包数据失败：\(error)")
        }
    }
    
    // MARK: - 加载所有数据
    func loadData() {
        do {
            // 1) 加载垃圾
            let garbageURL = try fileURL(for: garbageFileName)
            if FileManager.default.fileExists(atPath: garbageURL.path) {
                let gData = try Data(contentsOf: garbageURL)
                let gItems = try JSONDecoder().decode([BackpackGarbageItem].self, from: gData)
                garbageItems = gItems
            }
            
            // 2) 加载宝藏
            let treasureURL = try fileURL(for: treasureFileName)
            if FileManager.default.fileExists(atPath: treasureURL.path) {
                let tData = try Data(contentsOf: treasureURL)
                let tItems = try JSONDecoder().decode([BackpackTreasureItem].self, from: tData)
                treasureItems = tItems
            }
            
            // 3) 加载鱼篓
            let fishBusketURL = try fileURL(for: fishBusketFileName)
            if FileManager.default.fileExists(atPath: fishBusketURL.path) {
                let fbData = try Data(contentsOf: fishBusketURL)
                let fbItems = try JSONDecoder().decode([FishInFishBusket].self, from: fbData)
                fishBusketItems = fbItems
            }
            
            // 4) 加载鱼库
            let fishLibraryURL = try fileURL(for: fishLibraryFileName)
            if FileManager.default.fileExists(atPath: fishLibraryURL.path) {
                let flData = try Data(contentsOf: fishLibraryURL)
                let flItems = try JSONDecoder().decode([FishInFishBusket].self, from: flData)
                fishLibraryItems = flItems
            }
            
            print("✅ 已从文件加载背包数据（垃圾、宝藏、鱼篓、鱼库）")
        } catch {
            print("❌ 加载背包数据失败：\(error)")
        }
    }
    
    // MARK: - 文件路径
    private func fileURL(for fileName: String) throws -> URL {
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "PlayerBackpackManager", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "无法访问 Document 目录"])
        }
        return documentsDir.appendingPathComponent(fileName)
    }
    
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
    
    // MARK: - 示例：售卖全部
    func sellAllGarbage() {
        garbageItems.removeAll()
    }
    func sellAllTreasure() {
        treasureItems.removeAll()
    }
    func sellAllFishBusket() {
        fishBusketItems.removeAll()
    }
    
    // MARK: - 堆叠逻辑示例
    /// 垃圾
    func addGarbageItem(_ newItem: BackpackGarbageItem) {
        var remain = newItem.quantity
        while remain > 0 {
            if let idx = garbageItems.firstIndex(where: {
                $0.name == newItem.name && $0.quantity < garbageStackLimit
            }) {
                let capacity = garbageStackLimit - garbageItems[idx].quantity
                let used = min(remain, capacity)
                garbageItems[idx].quantity += used
                garbageItems[idx].totalCount += used
                garbageItems[idx].fishedCount += used
                remain -= used
            } else {
                var item = newItem
                item.quantity = min(remain, garbageStackLimit)
                item.totalCount = item.quantity
                item.fishedCount = item.quantity
                remain -= item.quantity
                garbageItems.append(item)
            }
        }
    }
    
    /// 宝藏
    func addTreasureItem(_ newItem: BackpackTreasureItem) {
        var remain = newItem.quantity
        while remain > 0 {
            if let idx = treasureItems.firstIndex(where: {
                $0.name == newItem.name && $0.quantity < treasureStackLimit
            }) {
                let capacity = treasureStackLimit - treasureItems[idx].quantity
                let used = min(remain, capacity)
                treasureItems[idx].quantity += used
                treasureItems[idx].totalCount += used
                treasureItems[idx].fishedCount += used
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
    
    // MARK: - 将鱼从鱼篓移到鱼库
    func moveFishToLibrary(_ fish: FishInFishBusket) {
        if let idx = fishBusketItems.firstIndex(where: { $0.id == fish.id }) {
            fishBusketItems.remove(at: idx)
            fishLibraryItems.append(fish)
        }
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
}


