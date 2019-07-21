//
//  OrzNFC+Constants.swift
//  OrzNFC
//
//  Created by joker on 2019/7/20.
//  Copyright © 2019 joker. All rights reserved.
//

extension OrzNFC {
    struct AlertMessage {
        static let ndefAlert = "Hold your iPhone near a writable NFC tag to update."
        static let tagAlert = "Hold your iPhone near a NFC tag to read."
        static let tagReadOnly = "Tag is read only."
        static let tagReadWrite = "Tag is readwrite."
        static let tagUnableConnect = "Unable to connect to tag."
        static let tagMoreThanOneFound = "More than 1 tag is detected. Please remove all tags and try again."
        
        // NDEF
        static let ndefNotCompliant = "Tag is not NDEF compliant."
        static let ndefQueryFailed = "Unable to query the NDEF status of tag."
        static let ndefUnknownStatus = "Unknown NDEF tag status."
        static let ndefWriteFailed  = "Write NDEF message failed."
        static let ndefWriteSuccessed = "Write NDEF message successful."
        
        
    }
}
