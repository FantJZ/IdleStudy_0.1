//
//  FishView.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/16.
//

import SwiftUI

struct FishView: View {
  
  @StateObject private var fishPresenter = FishPresenter()
  
  var body: some View {
    
    ZStack {
      Color
        .gray
        .ignoresSafeArea(edges: .all)
      
      ForegroundView()
        .environmentObject(fishPresenter)
    }
  }
}

#Preview {
  FishView()
}
