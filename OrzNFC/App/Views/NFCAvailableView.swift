//
//  NFCAvailableView.swift
//  OrzNFC
//
//  Created by joker on 2023/5/26.
//

import SwiftUI

struct NFCAvailableView: View {
    var body: some View {
        TabView {
            NDEFView()
                .tabItem {
                    VStack {
                        Image("NFC")
                        Text("NDEF")
                    }
                }

            OtherTagView()
                .tabItem {
                    Label("Other", systemImage: "sensor.tag.radiowaves.forward")
                }

        }
    }
}

struct NFCAvailableView_Previews: PreviewProvider {
    static var previews: some View {
        NFCAvailableView()
    }
}
