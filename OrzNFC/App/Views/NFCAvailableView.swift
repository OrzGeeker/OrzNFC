import SwiftUI

enum TabPageID {
    case ndef
    case tag
}

struct NFCAvailableView: View {
    
    @Environment(AppModel.self) var appModel
    
    @State private var selectedTab: TabPageID = .ndef
    
    @State private var actionType: ActionType = .read
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NDEFView(actionType: $actionType)
                .tabItem {
                    Label("NDEF", image: "NFC")
                }
                .tag(TabPageID.ndef)
            OtherTagView()
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
            .onTapGesture {
                appModel.startAction(
                    on: selectedTab,
                    actionType: actionType
                )
            }
            .offset(y: 200)
        })
    }
}

#Preview {
    NFCAvailableView()
        .environment(AppModel())
}
