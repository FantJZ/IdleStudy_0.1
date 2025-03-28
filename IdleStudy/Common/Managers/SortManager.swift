import Foundation
import SwiftUI

// MARK: - 排序类型
enum SortType: String, CaseIterable {
    case name = "名称"
    case rarity = "稀有度"
    case quality = "品质"
    case priceAscending = "价格升序"
    case priceDescending = "价格降序"
    case weightAscending = "重量升序"
    case weightDescending = "重量降序"
}

// MARK: - 稀有度等级
enum RarityLevel: Int, Comparable {
    case 普通 = 0
    case 稀有
    case 史诗
    case 传说
    case 至臻

    static func < (lhs: RarityLevel, rhs: RarityLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - 品质等级
enum QualityLevel: Int, Comparable {
    case 差劣 = 0
    case 不错
    case 均等
    case 良好
    case 完美
    case 绝佳

    static func < (lhs: QualityLevel, rhs: QualityLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - 可排序协议（提供字段支持）
protocol SortableItem {
    var nameString: String { get }
    var rarityLevel: RarityLevel? { get }
    var qualityLevel: QualityLevel? { get }
    var priceValue: Int? { get }
    var weightValue: Double? { get }
}

// MARK: - 排序器
struct SortManager {
    static func sort<T: SortableItem>(items: [T], by type: SortType) -> [T] {
        switch type {
        case .name:
            return items.sorted { $0.nameString < $1.nameString }

        case .rarity:
            return items.sorted { ($0.rarityLevel ?? .普通) < ($1.rarityLevel ?? .普通) }

        case .quality:
            return items.sorted { ($0.qualityLevel ?? .差劣) < ($1.qualityLevel ?? .差劣) }

        case .priceAscending:
            return items.sorted { ($0.priceValue ?? 0) < ($1.priceValue ?? 0) }

        case .priceDescending:
            return items.sorted { ($0.priceValue ?? 0) > ($1.priceValue ?? 0) }

        case .weightAscending:
            return items.sorted { ($0.weightValue ?? 0) < ($1.weightValue ?? 0) }

        case .weightDescending:
            return items.sorted { ($0.weightValue ?? 0) > ($1.weightValue ?? 0) }
        }
    }
}

struct SortMenuView: View {
    let title: String
    let sortTypes: [SortType]
    @Binding var selected: SortType
    var onSelect: (SortType) -> Void

    var body: some View {
        Menu(title) {
            ForEach(sortTypes, id: \.self) { type in
                Button {
                    selected = type
                    onSelect(type)
                } label: {
                    HStack {
                        Text(type.rawValue)
                        if selected == type {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
}
