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

#Preview("Text") {
    PayloadView(payload: .text)
}

#Preview("URL") {
    PayloadView(payload: .webSiteURL)
}

#Preview("Empty") {
    PayloadView(payload: .empty)
}
