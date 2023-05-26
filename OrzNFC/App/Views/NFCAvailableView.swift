//
//  NFCAvailableView.swift
//  OrzNFC
//
//  Created by joker on 2023/5/26.
//

import SwiftUI

enum TabPageID {
    case ndef
    case tag
}

struct NFCAvailableView: View {

    @State private var selectedTab: TabPageID = .ndef
    
    @State private var actionType: ActionType = .read

    var body: some View {
        TabView(selection: $selectedTab) {
            NDEFView(actionType: $actionType)
                .tabItem { Label("NDEF", image: "NFC") }
                .tag(TabPageID.ndef)
            OtherTagView()
                .tabItem { Label("Tag", systemImage: "sensor.tag.radiowaves.forward") }
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
                AppModel.startAction(on: selectedTab, actionType: actionType)
            }
            .offset(y: 200)
        })
    }
}

struct NFCAvailableView_Previews: PreviewProvider {
    static var previews: some View {
        NFCAvailableView()
    }
}
