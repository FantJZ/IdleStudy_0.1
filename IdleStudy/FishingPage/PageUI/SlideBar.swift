import SwiftUI

struct SlideBar: View {
    @Binding var selectedTime: Double

    // 小时
    var selectedHours: Int {
        Int(selectedTime / 60)
    }

    // 分钟（除去小时后剩余的分钟数）
    var selectedMinute: Int {
        Int(selectedTime - Double(selectedHours) * 60)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("选择时间：\(selectedHours) 小时 \(selectedMinute) 分钟")
                .font(.headline)

            Slider(value: $selectedTime, in: 0...720, step: 1)
                .padding(.horizontal)
                .onChange(of: selectedTime) { newValue in
                    // 当值为 0, 10, 20, 30... 等等时，触发一次震动
                    if newValue.truncatingRemainder(dividingBy: 1) == 0 {
                        // iOS 设备上的震动反馈
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                }
        }
        .padding(.all, 10)
        .background(Color.blue.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 5)

    }
}

#Preview {
    SlideBar(selectedTime: .constant(200))
}

