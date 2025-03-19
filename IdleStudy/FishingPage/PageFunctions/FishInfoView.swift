import Foundation
import SwiftUI

// MARK: - FishCalculations

struct FishInfoView: View {
  @State private var pondName: String = "小池塘"

  @State private var info: FishInfoItem?

  var body: some View {
    VStack(alignment: .leading) {
      Image(systemName: "\(self.info?.image ?? "")")
      Text("名称：\(self.info?.fishName ?? "")")
      Text("品质：\(self.info?.quality ?? "")")
      Text("重量：\(String(format: "%.2f", self.info?.weight ?? 0)) kg")
      Text("价格：\(self.info?.price ?? 0)")
      Text("稀有度：\(self.info?.rarity ?? "")")
    }
    .padding()
    .onAppear {
      let fishData = FishCache.shared.fishInfo(pondName)
      self.info = fishData
      
      if let validData = fishData {
        FishDataManager.shared.updateFishInfo(validData)
        printlog(info)
        
        saveToBusket()
        
      }
    }
  }
  
  func saveToBusket() {
//      guard let fish = FishDataManager.shared.currentFishInfo else {
//          print("⚠️ 没有可保存的鱼数据")
//          return
//      }
      
      let fishDict: [String: Any] = [ // 移除可选类型声明
          "image": self.info?.image ?? "",
          "name": self.info?.fishName ?? "",
          "quality": self.info?.quality ?? "",
          "weight": String(format: "%.2f", self.info?.weight ?? 0),
          "price": self.info?.price ?? 0,
          "rarity": self.info?.rarity ?? ""
      ]
      
      do {
          try FishBusketManager.shared.saveDictionary(fishDict) // 直接传递字典
          print("✅ 字典存储成功")
      } catch FishBusketManager.FileError.encodingFailed {
          print("❌ 数据编码失败")
      } catch {
          print("❌ 其他错误：\(error)")
      }
    
      do {
              let loadedData = try FishBusketManager.shared.loadDictionary()
              print("✅ 验证读取到的数据：\(loadedData)")
          } catch {
              print("❌ 验证失败：\(error)")
          }
      FishBusketManager.shared.debugFileStatus()
  }
}


#Preview {
  FishInfoView()
}
