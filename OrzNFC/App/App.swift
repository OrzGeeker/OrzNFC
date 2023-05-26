//
//  OrzNFCApp.swift
//  OrzNFC
//
//  Created by joker on 2023/5/22.
//

import SwiftUI

@main
struct OrzNFCApp: App {
    let appName: String = (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? ""
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    @StateObject private var model = AppModel()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environmentObject(model)
                    .alert(isPresented: $model.showAlert) {
                        Alert(title: Text(model.alertMessage))
                    }
                    .ignoresSafeArea()
                    .navigationTitle(appName)
            }
        }
    }
}
