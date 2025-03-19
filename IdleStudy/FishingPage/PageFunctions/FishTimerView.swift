import Combine
import SwiftUI

// MARK: - 正向计时

// struct CountUpTimerView: View {
//    @State var secondElapse: Int = 0
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//
//    var body: some View {
//        Text("经历时间：\(timeString)")
//            .onReceive(timer) { _ in
//                secondElapse += 1
//            }
//    }
//
//    var timeString: String {
//        let hours = secondElapse / 3600
//        let minutes = (secondElapse % 3600) / 60
//        let seconds = secondElapse % 60
//        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
//    }
// }

// MARK: - 倒计时（selectedTime 以“分钟”为单位）

struct FishTimerView: View {
  @EnvironmentObject private var presenter: FishPresenter

  var body: some View {
    Text("剩余时间：\(self.presenter.timeString)")
      .onAppear {
        self.presenter.startTimer()
      }
      .onDisappear {
        self.presenter.stopTimer()
      }
      .onChange(of: self.presenter.selectedTime) { newValue in
        self.presenter.startTimer()
      }
  }
}
