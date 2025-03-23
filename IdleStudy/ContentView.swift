import SwiftUI

struct ContentView: View {
    var body: some View {
        PondSelectionView()
    }
}
// 预览
#Preview {
    ContentView()
            .environmentObject(PondStore())
}

