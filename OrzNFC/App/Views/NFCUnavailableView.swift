//
//  NFCUnavailableView.swift
//  OrzNFC
//
//  Created by joker on 2023/5/26.
//

import SwiftUI

struct NFCUnavailableView: View {
    var body: some View {
        VStack {
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .resizable()
                .frame(width: 50, height: 50)
            Text("NFC Unavailable")
                .bold()
                .font(.title)
        }
    }
}

struct NFCUnavailableView_Previews: PreviewProvider {
    static var previews: some View {
        NFCUnavailableView()
    }
}
