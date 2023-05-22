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
            Button("Start Scan NDEF", action: AppModel.startScanNDEF)
                .buttonStyle(.bordered)
            
            Button("Start Scan Tags", action: AppModel.startScanTags)
                .buttonStyle(.bordered)
        }
        .padding()
        .alert(isPresented: $appModel.showAlert) {
            Alert(title: Text(appModel.alertMessage))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
