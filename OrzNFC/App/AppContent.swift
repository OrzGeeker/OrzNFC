//
//  ContentView.swift
//  OrzNFC
//
//  Created by joker on 2023/5/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        if AppModel.canRead() {
            NFCAvailableView()
        } else {
            NFCUnavailableView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
