@preconcurrency import CryptoTokenKit

extension TKSmartCardSlot.State {
    var log: Void {
        var desc: String
        switch self {
        case .missing:
            desc = "读卡器被拔掉了"
        case .empty:
            desc = "没有放上智能卡"
        case .muteCard:
            desc = "智能卡无响应命令"
        case .probing:
            desc = "正在探测智能卡"
        case .validCard:
            desc = "智能卡准备就绪"
        @unknown default:
            desc = "未知状态"
        }
        desc.log
    }
}

extension OrzNFCModel {
    
    func processState(_ state: TKSmartCardSlot.State, of slot: TKSmartCardSlot) {
        state.log
        guard state == .validCard
        else {
            return
        }
        self.processCard(of: slot)
    }
    
    func processCard(of slot: TKSmartCardSlot) {
        slot.name.log("Smart Card Reader Name")
        slot.maxInputLength.log("APDU MaxInputLength(Reader -> Card)")
        slot.maxOutputLength.log("APDU MaxOutputLength(Card -> Reader)")
        guard let atr = slot.atr
        else {
            OrzNFCError.notReceiveAnswerToReset.log
            return
        }
        // Answer to Reset
        atr.bytes.log("Card ATR")
        
        // parse ATR
        parseATR(atr)
        
        // read
        readAllData(with: slot)
        
        // write sector 0 block 0
        writeData(with: slot)
    }
    
    func parseATR(_ atr: TKSmartCardATR) {
        
        // RID
        var rid: String
        switch atr.bytes[7...11] {
        case .SubSequence([0xA0, 0x00, 0x00, 0x03, 0x06]):
            rid = "PC/SC Workgroup"
        default:
            rid = "Unknown"
        }
        rid.log("RID")
        
        // Standard
        var standard: CardStandard
        switch atr.bytes[12..<13] {
        case .SubSequence([0x03]):
            standard = .iso_14443A_Part3
        default:
            standard = .unknown
            break
        }
        standard.log
        
        // Card Name
        var cardName: CardName
        switch atr.bytes[13...14] {
        case .SubSequence([0x00, 0x01]):
            cardName = .mifare_classic_1K
        case .SubSequence([0x00, 0x02]):
            cardName = .mifare_classic_4K
        case .SubSequence([0x00, 0x03]):
            cardName = .mifare_ultralight
        case .SubSequence([0x00, 0x26]):
            cardName = .mifare_mini
        case .SubSequence([0xF0, 0x04]):
            cardName = .topaz_jewel
        case .SubSequence([0xF0, 0x11]):
            cardName = .feliCa_212K
        case .SubSequence([0xF0, 0x12]):
            cardName = .feliCa_424K
        default:
            cardName = .unknown
        }
        cardName.log
        
        atr.protocols.log("Card Protocols")
        atr.historicalBytes.log("Historical Bytes")
    }
    
    func readAllData(with slot: TKSmartCardSlot) {
        guard let card = slot.makeSmartCard()
        else {
            OrzNFCError.makeSmartCardFailed.log
            return
        }
        Task {
            try await card.withSession {
                try await card.transmit(
                    .loadAuthKey(
                        keyNumber: 0x00,
                        keyBytes: TransportConfiguration.keyA
                    )
                )
                .log("Load Auth Keys In Location 0")
                
                try await card.transmit(
                    .loadAuthKey(
                        keyNumber: 0x01,
                        keyBytes: TransportConfiguration.keyB
                    )
                )
                .log("Load Auth Keys In Location 1")
                
                for sectorNumber in 0 ..< 16 {
                    let blockStart = sectorNumber * 4
                    try await card
                        .transmit(
                            .authentication(
                                obsolete: false,
                                blockNumber: UInt8(blockStart),
                                keyType: 0x60,
                                keyNumber: 0x00
                            )
                        )
                        .log("auth sector \(sectorNumber) with method A Location 0 of Key")
                    for blockNumber in blockStart ..< blockStart + 4 {
                        try await card
                            .transmit(
                                .readBinary(
                                    blockNumber: UInt8(blockNumber),
                                    bytesCount: 0x10
                                )
                            )
                            .log("Block \(String(format: "%02d", blockNumber))")
                        
                    }
                }
            }
        }
    }
    
    func writeData(with slot: TKSmartCardSlot) {
        guard let card = slot.makeSmartCard()
        else {
            OrzNFCError.makeSmartCardFailed.log
            return
        }
        Task {
            try await card.withSession {
                let keyNumber: UInt8 = 0x00
                try await card.transmit(
                    .loadAuthKey(
                        keyNumber: keyNumber,
                        keyBytes: TransportConfiguration.keyA
                    )
                )
                .log("Load Auth Keys In Location 0")
                
                
                let sectorNumber: UInt8 = 0x00
                try await card.transmit(
                    .authentication(
                        obsolete: false,
                        blockNumber: sectorNumber,
                        keyType: AuthKeyType.A.rawValue,
                        keyNumber: keyNumber
                    )
                )
                .log("auth sector \(sectorNumber) with method A Location 0 of Key")
                
                let blockNumber: UInt8 = 0x00
                
                try await card.transmit(
                    .updateBinary(
                        blockNumber: blockNumber,
                        bytesCount: 0x10,
                        bytes: [
                            0x57, 0x96, 0x0C, 0xB5, 0x78, 0x08, 0x04, 0x00,
                            0x02, 0x5D, 0xA7, 0x74, 0xCD, 0xF1, 0x91, 0x1D
                        ]
                    )
                )
                .log("Write Block \(blockNumber)")
                
                try await card.transmit(
                    .authentication(
                        obsolete: false,
                        blockNumber: sectorNumber,
                        keyType: AuthKeyType.A.rawValue,
                        keyNumber: keyNumber
                    )
                )
                .log("auth sector \(sectorNumber) with method A Location 0 of Key")
                
                try await card.transmit(
                    .readBinary(
                        blockNumber: blockNumber,
                        bytesCount: 0x10
                    )
                )
                .log("Read Block \(blockNumber)")
            }
        }
    }
}
