import Foundation
import SwiftUI

// MARK: - FishCalculations

struct FishInfoView: View {
  @State private var pondName: String = "小池塘"

  @State private var info: FishInfoItem?

  var body: some View {
    VStack(alignment: .leading) {
      Text("名称：\(self.info?.fishName ?? "")")
      Text("品质：\(self.info?.quality ?? "")")
      Text("重量：\(String(format: "%.2f", self.info?.weight ?? 0)) kg")
      Text("价格：\(self.info?.price ?? 0)")
      Text("稀有度：\(self.info?.rarity ?? "")")
    }
    .padding()
    .onAppear {
      self.info = FishCache.shared.fishInfo(self.pondName)
      printlog(info)
    }
  }
}

#Preview {
  FishInfoView()
}
