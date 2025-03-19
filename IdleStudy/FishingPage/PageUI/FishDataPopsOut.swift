//
//  FishDataPopsOut.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/18.
//

import SwiftUI

struct FishDataPopsOut: View {
  var body: some View {
    Rectangle()
      .fill(Color.gray.opacity(0.5))
      .overlay(
        FishInfoView()
      )
      .frame(width: 200, height: 300)
      .position(
        x: UIScreen.main.bounds.midX,
        y: UIScreen.main.bounds.midY
      )
  }
}

#Preview {
  FishDataPopsOut()
}
