//
//  AppModel.swift
//  OrzNFC
//
//  Created by joker on 2023/5/22.
//

import Foundation

class AppModel: ObservableObject {
    
    let appName: String = Bundle.main.infoDictionary?["CFBundleName"] as! String
    
    @Published var showAlert: Bool = false
    var alertMessage: String = "" {
        didSet {
            showAlert = true
        }
    }
    
    static private let nfc = OrzNFC()
}

extension AppModel {
    
    static func startScanNDEF() {
        nfc.ndefScan()
    }
    
    
    static func startScanTags() {
        nfc.tagScan()
    }

    static func canRead() -> Bool { nfc.canRead }
}
