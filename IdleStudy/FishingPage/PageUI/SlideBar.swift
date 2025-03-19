//
//  SlideBar.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/17.
//

import SwiftUI

struct SlideBar: View {
    @Binding var selectedTime: Double

    // 将原先的 let 改为计算属性
    var selectedHours: Int {
        Int(selectedTime / 60)
    }

    var selectedMinute: Int {
        // 注意这里需要把结果转换为 Int
        Int((selectedTime - (Double(selectedHours)) * 60))
    }

    var body: some View {
        Text("选择时间：\(selectedHours) 小时 \(selectedMinute) 分钟")
            .font(.headline)
        Slider(value: $selectedTime, in: 0...720, step: 1)
            .padding(.horizontal)
    }
}

#Preview {
    SlideBar(selectedTime: .constant(200))
}
