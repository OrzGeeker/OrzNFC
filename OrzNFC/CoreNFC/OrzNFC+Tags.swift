//
//  OrzNFC+Tags.swift
//  OrzNFC
//
//  Created by joker on 2019/7/21.
//  Copyright © 2019 joker. All rights reserved.
//

import CoreNFC

extension OrzNFC: NFCTagReaderSessionDelegate {
        
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        _ = tags.map{ print($0) }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
    }
}
