//
//  OrzNFC.swift
//  OrzNFC
//
//  Created by joker on 2019/7/20.
//  Copyright © 2019 joker. All rights reserved.
//

import CoreNFC

class OrzNFC: NSObject {

    static let `default` = OrzNFC()

    private override init() {}
    
    private var ndefReaderSession: NFCNDEFReaderSession?
    
    private var tagReaderSession: NFCTagReaderSession?
}

extension OrzNFC {
    
    func ndefScan() {
        
        guard NFCNDEFReaderSession.readingAvailable else {
            return
        }
        
        ndefReaderSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        ndefReaderSession?.alertMessage = AlertMessage.ndefAlert
        ndefReaderSession?.begin()
    }
    
    func tagScan(pollingOption: NFCTagReaderSession.PollingOption = .iso14443) {
        
        guard NFCNDEFReaderSession.readingAvailable else {
            return
        }
        
        tagReaderSession = NFCTagReaderSession(pollingOption: pollingOption, delegate: self, queue: nil)
        tagReaderSession?.alertMessage = AlertMessage.tagAlert
        tagReaderSession?.begin()
    }
}

