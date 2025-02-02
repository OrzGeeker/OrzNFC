import SwiftUI
import CoreNFC

enum TabPageID {
    case ndef
    case tag
}

struct NFCAvailableView: View {
    
    @Environment(AppModel.self) var appModel
    
    @State private var selectedTab: TabPageID = .ndef
    
    @State private var actionType: ActionType = .read
    
    @State private var tagPollingOption: NFCTagReaderSession.PollingOption = .iso14443
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NDEFView(actionType: $actionType)
                .tabItem {
                    Label("NDEF", image: "NFC")
                }
                .tag(TabPageID.ndef)
            OtherTagView(actionType: $actionType, pollingOption: $tagPollingOption)
                .tabItem {
                    Label("Tag", systemImage: "sensor.tag.radiowaves.forward")
                }
                .tag(TabPageID.tag)
        }
        .overlay(alignment: .center, content: {
            ZStack {
                let size: CGFloat = 80
                let iconSize = 0.7 * size
                Circle()
                    .fill(.green)
                    .frame(width: size, height: size)
                Image(systemName: "iphone.gen2.radiowaves.left.and.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconSize, height: iconSize)
            }
            .offset(y: 200)
            .onTapGesture {
                appModel.start(
                    on: selectedTab,
                    action: actionType,
                    tagPollingOption: tagPollingOption
                )
            }
        })
    }
}

#Preview {
    NFCAvailableView()
        .environment(AppModel())
}
