import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        if appModel.canRead {
            NFCAvailableView()
        } else {
            NFCUnavailableView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
