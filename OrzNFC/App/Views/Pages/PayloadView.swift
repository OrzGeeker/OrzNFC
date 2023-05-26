//
//  PayloadView.swift
//  OrzNFC
//
//  Created by joker on 2023/5/26.
//

import SwiftUI
import CoreNFC

struct PayloadView: View {

    let payload: NFCNDEFPayload

    var body: some View {

        let unsupportedPayload = Label("Unknown Payload Type", systemImage: "exclamationmark.shield")
            .foregroundColor(.red)

        VStack {
            if payload.typeNameFormat == .nfcWellKnown {
                if let uri = payload.wellKnownTypeURIPayload() {
                    Link(uri.absoluteString, destination: uri)
                } else if let text = payload.wellKnownTypeTextPayload().0 {
                    Text(text)
                } else {
                    unsupportedPayload
                }
            } else {
                unsupportedPayload
            }
        }
    }
}

struct PayloadView_Previews: PreviewProvider {
    static var previews: some View {

        PayloadView(
            payload: NFCNDEFPayload.wellKnownTypeTextPayload(
                string: "Hello", locale: .current)!
        )

        PayloadView(payload: NFCNDEFPayload.wellKnownTypeURIPayload(
            url: URL(string: "https://www.baidu.com")!)!
        )

        PayloadView(payload: NFCNDEFPayload(format: .empty, type: Data(), identifier: Data(), payload: Data())
        )
    }
}
