import SwiftUI

// MARK: - FishDataPopsOut
/// 负责：
/// 1. 在 onAppear 时获取鱼数据并存储到 info
/// 2. 根据 info?.rarity 动态设置背景渐变
/// 3. 把 info 传递给 FishInfoView 显示
struct FishDataPopsOut: View {
    @State private var pondName: String = "小池塘"
    @State private var info: FishInfoItem?
    
    var body: some View {
        ZStack {
            // 背景卡片
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(backgroundGradient(for: info?.rarity))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.7), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
            
            // 展示鱼信息的子视图
            FishInfoView(info: info)
                .padding()
        }
        .frame(width: 240, height: 340)
        .position(
            x: UIScreen.main.bounds.midX,
            y: UIScreen.main.bounds.midY - 40
        )
        .onAppear {
            // 1. 获取鱼数据
            let fishData = FishCache.shared.fishInfo()  // 无参数
            self.info = fishData
            
            // 2. 如果拿到数据，执行后续逻辑
            if let validData = fishData {
                // 加经验
                ExperienceManager.shared.addXP(validData.exp)
                // 同步图鉴
                FishGuideManager.shared.syncFromBusket()
                
                // 更新到 FishDataManager
                FishDataManager.shared.updateFishInfo(validData)
                print("✅ 获取到的鱼信息: \(validData)")
                
                // 将该鱼追加到鱼篓
                saveToBusket(fish: validData)
            }
        }
    }
    
    /// 将当前鱼信息追加保存到鱼篓
    private func saveToBusket(fish: FishInfoItem) {
        let newFish = FishInFishBusket(
            image: fish.image,
            name: fish.fishName,
            quality: fish.quality,
            weight: fish.weight,
            price: fish.price,
            rarity: fish.rarity,
            exp: fish.exp
        )
        
        do {
            try FishBusketManager.shared.saveFish(newFish)
            print("✅ 已追加保存一条新鱼: \(newFish)")
        } catch {
            print("❌ 保存鱼数据失败: \(error)")
        }
        
        do {
            let allFishes = try FishBusketManager.shared.loadAllFishes()
            print("✅ 验证读取到的数据：\(allFishes)")
        } catch {
            print("❌ 验证读取失败：\(error)")
        }
        
        FishBusketManager.shared.debugFileStatus()
    }
    
    /// 根据稀有度返回不同背景渐变
    private func backgroundGradient(for rarity: String?) -> LinearGradient {
        switch rarity {
        case "普通":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.4),
                    Color.gray.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "稀有":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.4),
                    Color.blue.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "史诗":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.4),
                    Color.purple.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "传说":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.yellow.opacity(0.5),
                    Color.orange.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "至臻":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.red.opacity(0.4),
                    Color.red.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            // 默认：蓝紫渐变
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.4),
                    Color.purple.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - FishInfoView
/// 只负责显示传进来的 FishInfoItem，不再自己获取数据
struct FishInfoView: View {
    let info: FishInfoItem?
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            
            // 顶部的鱼图片
            Image(info?.image ?? "")
                .resizable()
                .interpolation(.none)
                .antialiased(false)
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            // 两列布局：左列标签，右列对应数据
            HStack(alignment: .top, spacing: 16) {
                
                // 左列：标签
                VStack(alignment: .leading, spacing: 8) {
                    Text("名称：")
                    Text("品质：")
                    Text("重量：")
                    Text("价格：")
                    Text("稀有度：")
                    Text("经验值：")
                }
                .foregroundColor(.secondary)
                
                // 右列：具体数据
                VStack(alignment: .trailing, spacing: 8) {
                    Text(info?.fishName ?? "")
                    Text(info?.quality ?? "")
                    Text(String(format: "%.2f kg", info?.weight ?? 0))
                    Text("\(info?.price ?? 0)")
                    Text(info?.rarity ?? "")
                    Text("\(info?.exp ?? 0)")
                }
                .font(.headline)
            }
        }
        .padding()
        // 可以留给父视图决定 frame
    }
}

// MARK: - 预览
#Preview {
    FishDataPopsOut()
}
