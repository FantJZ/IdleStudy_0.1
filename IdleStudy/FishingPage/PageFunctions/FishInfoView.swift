import Foundation
import SwiftUI

// MARK: - FishCalculations

struct FishInfoView: View {
    @State private var pondName: String = "小池塘"
    @State private var info: FishInfoItem?

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: info?.image ?? "")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            Text("名称：\(info?.fishName ?? "")")
            Text("品质：\(info?.quality ?? "")")
            Text("重量：\(String(format: "%.2f", info?.weight ?? 0)) kg")
            Text("价格：\(info?.price ?? 0)")
            Text("稀有度：\(info?.rarity ?? "")")
        }
        .padding()
        .onAppear {
            // 从 FishCache 获取当前鱼信息
            let fishData = FishCache.shared.fishInfo(pondName)
            self.info = fishData
            
            // 同步更新到 FishDataManager
            if let validData = fishData {
                FishDataManager.shared.updateFishInfo(validData)
                print("✅ 获取到的鱼信息: \(validData)")
                
                // 将该鱼追加到鱼篓
                saveToBusket()
            }
        }
    }
    
    /// 将当前鱼信息追加保存到鱼篓
    func saveToBusket() {
        guard let info = self.info else {
            print("⚠️ 没有可保存的鱼数据")
            return
        }
        
        // 将 FishInfoItem 转换为 FishInFishBusket 结构
        let newFish = FishInFishBusket(
            image: info.image, name: info.fishName,
            quality: info.quality,
            weight: info.weight,
            price: info.price,
            rarity: info.rarity
        )
        
        // 调用 saveFish(_:) 追加保存
        do {
            try FishBusketManager.shared.saveFish(newFish)
            print("✅ 已追加保存一条新鱼: \(newFish)")
        } catch {
            print("❌ 保存鱼数据失败: \(error)")
        }
        
        // 验证文件中的全部鱼
        do {
            let allFishes = try FishBusketManager.shared.loadAllFishes()
            print("✅ 验证读取到的数据：\(allFishes)")
        } catch {
            print("❌ 验证读取失败：\(error)")
        }
        
        FishBusketManager.shared.debugFileStatus()
    }
}

#Preview {
    FishInfoView()
}

