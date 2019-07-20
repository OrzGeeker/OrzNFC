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
    
    private var readerSession: NFCNDEFReaderSession?
    
    private var tagReaderSession: NFCTagReaderSession?
}

extension OrzNFC {
    
    func scan() {
        
        guard NFCNDEFReaderSession.readingAvailable else {
            return
        }
        
        readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        readerSession?.alertMessage = Message.alert
        readerSession?.begin()
    }
    
    func readTag() {
        
        guard NFCNDEFReaderSession.readingAvailable else {
            return
        }
        
        tagReaderSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: nil)
        tagReaderSession?.alertMessage = Message.tagAlert
        tagReaderSession?.begin()
    }
}

extension OrzNFC: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    
    }
}

extension OrzNFC: NFCTagReaderSessionDelegate {
        
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
    
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        
    }
}
