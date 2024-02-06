//
//  main.swift
//  OrzNFCReader
//
//  Created by joker on 2022/7/12.
//  Copyright © 2022 joker. All rights reserved.
//

import CryptoTokenKit
import Combine

@main
struct OrzNFCReader {
    
    /// 智能卡管理器
    private static let manager: TKSmartCardSlotManager = {
        guard let mgr = TKSmartCardSlotManager.default
        else {
            fatalError("The com.apple.security.smartcard entitlement is required in order to use TKSmartCardSlotManager.")
        }
        return mgr
    }()
    
    /// 监听是否有读卡器插拔事件
    private static var slotPublisherCancellable: Cancellable?
    
    /// 读卡器插槽
    private static var cardSlots = [String: TKSmartCardSlot]()
    
    /// 读卡器状态监听
    private static var slotStatePublisherCancellables = [String: Cancellable]()
    
    /// 程序入口
    static func main() {
        
        slotPublisherCancellable = manager.publisher(for: \.slotNames).sink { slotNames in
            
            Task {
                
                for slotName in slotNames {
                    
                    guard let slot = await manager.getSlot(withName: slotName)
                    else {
                        "找不到读卡器 \(slotName)".log
                        continue
                    }
                    
                    // 存储读卡器实例
                    cardSlots[slotName] = slot
                    
                    // 监听读卡器状态变化
                    slotStatePublisherCancellables[slotName] = slot.publisher(for: \.state)
                        .filter { $0 != .probing }
                        .removeDuplicates()
                        .sink { state in
                            switch state {
                            case .missing:
                                "读卡器被拔掉了".log
                            case .empty:
                                "没有放上智能卡".log
                            case .muteCard:
                                "智能卡无响应命令".log
                            case .probing:
                                "正在探测智能卡".log
                            case .validCard:
                                "智能卡准备就绪".log
                                processCard(of: slot)
                            @unknown default:
                                fatalError("读卡器未知状态")
                            }
                        }
                }
                
            }
        }
        
        RunLoop.main.run()
    }
}

extension OrzNFCReader {
    
    static func processCard(of slot: TKSmartCardSlot) {
        
        Task {
            if let atr = slot.atr {
                slot.name.log("读卡器名称")
                atr.bytes.log("Card ATR")
                atr.protocols.log("Card Protocols")
                slot.maxInputLength.log("APDU MaxInputLength(Reader -> Card)")
                slot.maxOutputLength.log("APDU MaxOutputLength(Card -> Reader)")
            }
            guard let card = slot.makeSmartCard() else {
                "读卡器\(slot.name)上的卡片无效".log
                return
            }
            let success = try await card.beginSession()
            if success {
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
            card.endSession()
        }
    }
}
