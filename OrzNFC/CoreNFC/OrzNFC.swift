//
//  OrzNFC.swift
//  OrzNFC
//
//  Created by joker on 2019/7/20.
//  Copyright © 2019 joker. All rights reserved.
//

import CoreNFC
import Combine

class OrzNFC: NSObject {
    
    private var ndefReaderSession: NFCNDEFReaderSession?
    
    private var tagReaderSession: NFCTagReaderSession?

    var action: ActionType?

    let ndefMessageSubject = PassthroughSubject<NFCNDEFMessage, Never>()
}

extension OrzNFC {
    
    /// 设置是否支持读取NFC标签信息
    var canRead: Bool { NFCReaderSession.readingAvailable }
    
    
    func ndefScan() {
        
        guard canRead else {
            return
        }
        
        ndefReaderSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        ndefReaderSession?.alertMessage = AlertMessage.ndefAlert
        ndefReaderSession?.begin()
    }
        
    func tagScan() {
        
        guard canRead else {
            return
        }
        
        tagReaderSession = NFCTagReaderSession(pollingOption: [.iso14443, .iso18092, .iso15693, .pace], delegate: self, queue: nil)
        tagReaderSession?.alertMessage = AlertMessage.tagAlert
        tagReaderSession?.begin()
    }
}
