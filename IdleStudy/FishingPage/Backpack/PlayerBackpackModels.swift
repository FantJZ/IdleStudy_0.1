import Foundation

// MARK: - 垃圾物品

struct BackpackGarbageItem: Identifiable, Codable {
    var id: UUID
    let name: String
    let price: Int
    let pond: String
    let description: String
    let image: String
    
    /// 当前背包中该物品的数量
    var quantity: Int
    
    /// 总数 & 钓到的总数
    var totalCount: Int
    var fishedCount: Int
    
    /// 提供一个带默认值的初始化器，保证在外部不传 id 时也能自动生成
    init(
        id: UUID = UUID(),
        name: String,
        price: Int,
        pond: String,
        description: String,
        quantity: Int,
        totalCount: Int,
        fishedCount: Int,
        image: String
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.pond = pond
        self.description = description
        self.quantity = quantity
        self.totalCount = totalCount
        self.fishedCount = fishedCount
        self.image = image
    }
}

// MARK: - 宝藏物品

struct BackpackTreasureItem: Identifiable, Codable {
    var id: UUID
    let name: String
    let price: Int
    let pond: String
    let rarity: String
    let exp: Int
    let description: String
    
    var quantity: Int
    var totalCount: Int
    var fishedCount: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        price: Int,
        pond: String,
        rarity: String,
        exp: Int,
        description: String,
        quantity: Int,
        totalCount: Int,
        fishedCount: Int
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.pond = pond
        self.rarity = rarity
        self.exp = exp
        self.description = description
        self.quantity = quantity
        self.totalCount = totalCount
        self.fishedCount = fishedCount
    }
}
