//
//  IdleStudyApp.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/16.
//

import SwiftUI

@main
struct IdleStudyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PondStore())
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .background || newPhase == .inactive {
                        PlayerBackpackManager.shared.saveData()
                    }
                }
        }
    }
}
