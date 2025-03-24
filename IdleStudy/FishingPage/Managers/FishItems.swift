import Foundation

// MARK: - Fish

struct Fish: Codable {
    let name: String
    let image: String
    let rarity: String
    let pond: String          // 从 JSON 里解析到的池塘名
    let maximumWeight: Double
    let minimumWeight: Double
    let price: Int
    let exp: Int

    enum CodingKeys: String, CodingKey {
        case name
        case image
        case rarity
        case pond
        case maximumWeight = "maximum weight"
        case minimumWeight = "minimum weight"
        case price
        case exp
    }

    var infoItem: FishInfoItem {
        // 计算质量、重量
        let (quality, weight) = readFishWeight()
        // 计算价格
        let price = readFishPrice(fishWeight: weight, fishQuality: quality)
        // 获取稀有度
        let rarity = readFishRarity()

        return .init(
            fishName: name,
            quality: quality,
            weight: weight,
            price: price,
            rarity: rarity,
            image: image,
            exp: exp
        )
    }
}

extension Fish {
    /// 读取鱼自身的稀有度（这里可能直接返回 self.rarity）
    func readFishRarity() -> String {
        return self.rarity
    }

    /// 计算重量 & 品质
    func readFishWeight() -> (quality: String, weight: Double) {
        let minW = self.minimumWeight
        let maxW = self.maximumWeight
        let diff = maxW - minW
        
        let weightMin1 = minW + (diff / 5) * 1
        let weightMin2 = minW + (diff / 5) * 2
        let weightMin3 = minW + (diff / 5) * 3
        let weightMin4 = minW + (diff / 5) * 4

        // 用你已有的 RandomEvent(...) 函数
        let result = RandomEvent(5, 2, 3, 5, 2, 1)

        var quality = ""
        var rangeMin = minW
        var rangeMax = maxW

        switch result {
        case 1:
            quality = "差劣"
            rangeMin = minW
            rangeMax = weightMin1
        case 2:
            quality = "不错"
            rangeMin = weightMin1
            rangeMax = weightMin2
        case 3:
            quality = "均等"
            rangeMin = weightMin2
            rangeMax = weightMin3
        case 4:
            quality = "良好"
            rangeMin = weightMin3
            rangeMax = weightMin4
        case 5:
            quality = "完美"
            rangeMin = weightMin4
            rangeMax = maxW
        default:
            break
        }

        // 在对应区间随机一个重量，保留两位小数
        let weight = Double.random(in: rangeMin ... rangeMax).truncated(to: 2)
        // 如果正好达到最大值，则设为“绝佳”
        if weight == maxW {
            quality = "绝佳"
        }
        return (quality, weight)
    }

    /// 计算价格
    func readFishPrice(fishWeight: Double, fishQuality: String) -> Int {
        let basePrice = Double(price)
        let maxW = self.maximumWeight
        let weightFactor = (fishWeight / maxW) * basePrice

        var qualityFactor = 1.0
        switch fishQuality {
        case "差劣":
            qualityFactor = 1.0
        case "不错":
            qualityFactor = 1.5
        case "均等":
            qualityFactor = 2.0
        case "良好":
            qualityFactor = 2.5
        case "完美":
            qualityFactor = 3.0
        case "绝佳":
            qualityFactor = 50.0
        default:
            qualityFactor = 1.0
        }

        var finalPrice = (basePrice + weightFactor) * qualityFactor
        
        // 如果想让“山涧溪流”池塘的鱼价格翻倍（示例）
        if self.pond == "山涧溪流" {
            finalPrice *= 2
        }
        
        return Int(finalPrice)
    }
}

// MARK: - FishInfoItem

struct FishInfoItem {
    let fishName: String
    let quality: String
    let weight: Double
    let price: Int
    let rarity: String
    let image: String
    let exp: Int
}



