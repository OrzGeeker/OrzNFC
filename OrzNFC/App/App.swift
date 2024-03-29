//
//  OrzNFCApp.swift
//  OrzNFC
//
//  Created by joker on 2023/5/22.
//

import SwiftUI

@main
struct OrzNFCApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    @StateObject private var model = AppModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .alert(isPresented: $model.showAlert) {
                    Alert(title: Text(model.alertMessage))
                }
                .ignoresSafeArea()
        }
    }
}
