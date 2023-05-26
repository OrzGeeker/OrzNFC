//
//  NDEFView.swift
//  OrzNFC
//
//  Created by joker on 2023/5/26.
//

import SwiftUI

struct NDEFView: View {
    var body: some View {
        Button("Start Scan NDEF", action: AppModel.startScanNDEF)
    }
}

struct NDEFView_Previews: PreviewProvider {
    static var previews: some View {
        NDEFView()
    }
}
