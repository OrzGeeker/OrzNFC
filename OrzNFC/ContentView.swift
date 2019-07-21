//
//  ContentView.swift
//  OrzNFC
//
//  Created by joker on 2019/7/20.
//  Copyright © 2019 joker. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button(action: {
                OrzNFC.default.tagScan()
            }) {
                HStack {
                    Text("Tags")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom)
            Button(action: {
                OrzNFC.default.ndefScan()
            }) {
                HStack {
                    Text("NDEF")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top)
        }
    }
} 

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
