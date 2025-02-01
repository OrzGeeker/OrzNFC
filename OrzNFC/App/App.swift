import SwiftUI

@main
struct OrzNFCApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    @StateObject private var model = AppModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
                .alert(isPresented: $model.showAlert) {
                    Alert(title: Text(model.alertMessage))
                }
                .ignoresSafeArea()
        }
    }
}
