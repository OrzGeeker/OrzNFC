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
        guard let mgr = TKSmartCardSlotManager.default else {
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
                        print("找不到读卡器 \(slotName)")
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
                                print("读卡器被拔掉了")
                            case .empty:
                                print("没有放上智能卡")
                            case .muteCard:
                                print("智能卡无响应命令")
                            case .probing:
                                print("正在探测智能卡")
                            case .validCard:
                                print("智能卡准备就绪")
                                dumpCardInfo(of: slot)
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
    
    /// 打印智能卡相关信息
    static func dumpCardInfo(of slot: TKSmartCardSlot) {
        if let atr = slot.atr {
            print("读卡器: \(slot.name)")
            print("Card ATR: \(atr.bytes.hexString)")
            print("Card Protocols: \(atr.protocols)")
            print("APDU MaxInputLength(Reader -> Card): \(slot.maxInputLength)")
            print("APDU MaxOutputLength(Card -> Reader): \(slot.maxOutputLength)")
        }
    }
    
    static func processCard(of slot: TKSmartCardSlot) {
        Task {
            guard let card = slot.makeSmartCard() else {
                print("读卡器\(slot.name)上的卡片无效")
                return
            }
            let success = try await card.beginSession()
            if success {
                print(card.allowedProtocols)
                print(card.currentProtocol)
                // Get firmware version of the reader
                if let firewareVersion = try await card.transmit(ACR122UA9.Command.firmwareVersion.request).asciiString {
                    print("fireware version: \(firewareVersion)")
                }
                // Get the PICC operating parameter
                let reply = try await card.transmit(ACR122UA9.Command.piccOpParameter.request)
                if reply.first == ACR122UA9.Status.success.rawValue {
                    print("picc op params: \(reply[1...].hexString)")
                }
                // Set the PICC operating parameter
                var ret: Data
                ret = try await card.transmit(ACR122UA9.Command.setPiccOpParameter(0b111_00001).request)
                if ret.first == ACR122UA9.Status.success.rawValue {
                    print("changed picc op params: \(ret[1...].hexString)")
                }
                
                // Set Timeout Parameter
                ret = try await card.transmit(ACR122UA9.Command.setTimeoutParameter(0x01).request)
                if ret.first == ACR122UA9.Status.success.rawValue {
                    print("set timeout success: \(ret[1...].hexString)")
                } else {
                    print("set timeout failure")
                }
                
                // Get current settings of contactless interface
                ret = try await card.transmit(ACR122UA9.Command.currentSettings.request)
                print("settings: \(ret.hexString)")
            }
            card.endSession()
        }
    }
}
