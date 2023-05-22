//
//  OrzNFC+NDEF.swift
//  OrzNFC
//
//  Created by joker on 2019/7/21.
//  Copyright © 2019 joker. All rights reserved.
//

import CoreNFC

extension OrzNFC: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        "ndef reader session become active".printDebugInfo()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                print(readerError.localizedDescription)
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        _ = messages.map { print($0) }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = AlertMessage.tagMoreThanOneFound
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = AlertMessage.tagUnableConnect
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = AlertMessage.ndefQueryFailed
                    session.invalidate()
                    return
                }
                print("capacity: \(capacity)")
                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = AlertMessage.ndefNotCompliant
                    session.invalidate()
                case .readOnly:
                    session.alertMessage = AlertMessage.tagReadOnly
                    session.invalidate()
                case .readWrite:
                    if let payload = NFCNDEFPayload.wellKnownTypeURIPayload(string: "https://www.baidu.com") {
                        let message: NFCNDEFMessage = .init(records: [payload])
                        tag.writeNDEF(message, completionHandler: { (error: Error?) in
                            if nil != error {
                                session.invalidate(errorMessage:"\(error!)")
                            } else {
                                session.alertMessage = AlertMessage.ndefWriteSuccessed
                                session.invalidate()
                            }
                        })
                    }
                    
//                    tag.readNDEF { (message: NFCNDEFMessage?, error: Error?) in
//                        print(message)
//                        session.invalidate()
//                    }
                @unknown default:
                    session.alertMessage = AlertMessage.ndefUnknownStatus
                    session.invalidate()
                }
            })
        })
        
    }
}
