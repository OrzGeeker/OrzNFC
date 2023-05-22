//
//  ContentView.swift
//  OrzNFC
//
//  Created by joker on 2023/5/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var appModel: AppModel
    
    @State private var nfcAvailable: Bool = false
    
    var body: some View {
        VStack {
            if AppModel.canRead() {
                Button("Start Scan NDEF", action: AppModel.startScanNDEF)
                Button("Start Scan Tags", action: AppModel.startScanTags)
            } else {
                VStack {
                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text("NFC Unavailable")
                        .bold()
                        .font(.title)
                }
                .offset(y: -30)
            }
        }
        .buttonStyle(.bordered)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
