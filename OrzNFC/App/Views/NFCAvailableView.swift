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
                Circle()
                    .fill(.green)
                    .frame(width: 100, height: 100)
                Image(systemName: "iphone.gen2.radiowaves.left.and.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
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
