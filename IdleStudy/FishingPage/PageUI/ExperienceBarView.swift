//
//  XPView.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/22.
//

import SwiftUI

// 经验管理器：负责记录和更新玩家的等级与经验
class ExperienceManager: ObservableObject {
    // 单例
    static let shared = ExperienceManager()
    
    // 使用 AppStorage 实现持久化
    @AppStorage("playerLevel") var level: Int = 0
    @AppStorage("playerXP") var currentXP: Int = 0
    
    // 计算当前等级升级所需的经验
    var xpForNextLevel: Int {
        if level < 1000 {
            // 例如 level=150，150/100=1，所以每级需 (1+1)*100 = 200
            return ((level / 100) + 1) * 100
        } else {
            return 1000
        }
    }
    
    // 添加经验值并处理自动升级
    func addXP(_ amount: Int) {
        var xpToAdd = amount
        while xpToAdd > 0 {
            let xpNeeded = xpForNextLevel - currentXP
            if xpToAdd >= xpNeeded {
                xpToAdd -= xpNeeded
                level += 1
                currentXP = 0
            } else {
                currentXP += xpToAdd
                xpToAdd = 0
            }
        }
    }
}

// 经验条视图：左侧显示圆形等级，右侧显示进度条
struct ExperienceBarView: View {
    @ObservedObject var experienceManager: ExperienceManager
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧圆形显示等级
            ZStack {
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: 35, height: 35)
                    .shadow(radius: 5)
                Text("\(experienceManager.level)")
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(.black)
                    .font(.headline)
            }
            
            // 右侧经验进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景条
                    Rectangle()
                        .frame(height: 20)
                        .opacity(0.3)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    // 前景进度条
                    Rectangle()
                        .foregroundStyle(Color.green)
                        .frame(width: progressWidth(totalWidth: geometry.size.width), height: 20)
                        .cornerRadius(10)
                        .animation(.linear, value: experienceManager.currentXP)
                        .shadow(radius: 5)
                }
            }
            .frame(height: 20)
        }
        .frame(width: 300, height: 30)
        .padding(.all, 10)
        .background(Color.blue.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    // 计算进度条宽度
    private func progressWidth(totalWidth: CGFloat) -> CGFloat {
        let progress = CGFloat(experienceManager.currentXP) / CGFloat(experienceManager.xpForNextLevel)
        return totalWidth * progress
    }
}


#Preview {
    ExperienceBarView(experienceManager: ExperienceManager())
}
