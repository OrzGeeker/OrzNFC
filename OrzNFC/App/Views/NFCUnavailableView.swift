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

#Preview {
    NFCUnavailableView()
}
