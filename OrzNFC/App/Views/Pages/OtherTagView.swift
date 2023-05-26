//
//  OtherTagView.swift
//  OrzNFC
//
//  Created by joker on 2023/5/26.
//

import SwiftUI

struct OtherTagView: View {
    var body: some View {
        Button("Start Scan Tags", action: AppModel.startScanTags)
    }
}

struct OtherTagView_Previews: PreviewProvider {
    static var previews: some View {
        OtherTagView()
    }
}
