//
//  CoinsView.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/26.
//

import SwiftUI

struct CoinsView: View {
    @ObservedObject private var manager = CoinsManager.shared
    @State private var showFull = false

    var body: some View {
        VStack(spacing: 4) {
            Text(showFull ? manager.fullFormattedCoins() : manager.formattedCoins() + "金币")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(10)
                .onTapGesture {
                    withAnimation {
                        showFull.toggle()
                    }
                }
        }
    }
}

#Preview{
    CoinsView()
}
