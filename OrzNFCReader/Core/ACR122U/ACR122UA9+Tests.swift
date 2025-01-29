//
//  ACR122UA9+Tests.swift
//  OrzNFCReader
//
//  Created by joker on 2/7/24.
//

import CryptoTokenKit

extension ACR122UA9 {
    static func runTests(for card: TKSmartCard) {
        Task {
            try await card.withSession {
                try await card.transmit(.UID).log("GET UID")
                
                try await card.transmit(.ATS).log("GET ATS")
                
                try await card.transmit(
                    .loadAuthKey(keyNumber: 0x00, keyBytes: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
                ).log("Load Auth Keys In Location 0")
                
                try await card.transmit(
                    .loadAuthKey(keyNumber: 0x01, keyBytes: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00])
                ).log("Load Auth Keys In Location 1")
                
                try await card.transmit(
                    .authentication(obsolete: false, blockNumber: 0x03, keyType: 0x60, keyNumber: 0x00)
                ).log("auth block 3 with method A Location 0 of Key")
                
                try await card.transmit(
                    .readBinary(blockNumber: 0x03, bytesCount: 0x10)
                ).log("Read Block 3")
                
                try await card.transmit(
                    .authentication(obsolete: false, blockNumber: 0x04, keyType: 0x60, keyNumber: 0x00)
                ).log("auth block 4 with method A Location 0 of Key")
                
                try await card.transmit(
                    .readBinary(blockNumber: 0x04, bytesCount: 0x10)
                ).log("Read Block 4")
                
                try await card.transmit(
                    .updateBinary(blockNumber: 0x04, bytesCount: 0x10, bytes: [
                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
                    ])
                ).log("Update Binary")
                
                try await card.transmit(
                    .valueBlockOp(blockNumber: 0x04, operation: 0x00, valueBytes: [
                        0x00, 0x00, 0x00, 0x00
                    ])
                ).log("store 0 value into value block 4")
                
                try await card.transmit(
                    .valueBlockOp(blockNumber: 0x04, operation: 0x01, valueBytes: [
                        0x00, 0x00, 0x00, 0x09
                    ])
                ).log("increment by 9 of value block 4")
                
                try await card.transmit(
                    .valueBlockOp(blockNumber: 0x04, operation: 0x02, valueBytes: [
                        0x00, 0x00, 0x00, 0x04
                    ])
                ).log("decrement by 4 of value block 4")
                
                try await card.transmit(.readValueBlock(blockNumber: 0x03))
                    .log("read value block 3")
                
                try await card.transmit(.readValueBlock(blockNumber: 0x04))
                    .log("read value block 4")
                
                try await card.transmit(.restoreValueBlock(sourceBlock: 0x03, targetBlock: 0x04))
                    .log("restore value block 4 with value block 3")
                
                try await card.transmit(.readValueBlock(blockNumber: 0x04))
                    .log("read value block 4")
                
                try await card.transmit(.directTransmit(payload: [0x00, 0x00, 0x00, 0x01]))
                    .log("direct transmit")
                
                try await card.transmit(
                    .ledAndBuzzer(ledStatus: 0b00011111, blinkDuration: [
                        0x01, 0x01, 0x01, 0x00
                    ])
                ).log("led and buzzer status control")
                
                try await card.transmit(.iso144434AATS).log("iso14443-4A ATS")
                
                try await card.transmit(.buzzer(isOn: false)).log("buzzer off")
                
                try await card.transmit(
                    .custom(bytes: [
                        0x00, 0x84, 0x00, 0x00, 0x08
                    ])
                ).log("custom bytes")
                
                try await card.transmit(.firmwareVersion).asciiString?.log("Fireware Version")
                try await card.transmit(.piccOpParameter).log("Get PICC OP Params")
                try await card.transmit(.setPiccOpParameter(0b111_00001)).log("Set PICC OP Params")
                try await card.transmit(.setTimeoutParameter(0x01)).log("Set Timeout Parameter")
                try await card.transmit(.settings).log("Settings")
            }
        }
    }
}
