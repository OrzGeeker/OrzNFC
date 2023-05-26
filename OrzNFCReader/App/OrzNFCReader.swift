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
    
    /// 读卡器名称
    private static let cardReaderName = ACR122UA9.name
    
    /// 读卡器插槽
    private static var cardReaderSlot: TKSmartCardSlot?
    
    /// 读卡器状态监听
    private static var slotStatePublisherCancellable: Cancellable?
    
    /// 程序入口
    static func main() {
        
        slotPublisherCancellable = manager.publisher(for: \.slotNames).sink { slotNames in

            guard slotNames.contains(cardReaderName) else {
                print("读卡器 \(cardReaderName) 未连接")
                slotStatePublisherCancellable?.cancel()
                slotStatePublisherCancellable = nil
                cardReaderSlot = nil
                return
            }
            
            Task {
                guard cardReaderSlot == nil else {
                    print("目前连接的所有读卡器：\(slotNames)")
                    return
                }
                
                guard let slot = await manager.getSlot(withName: cardReaderName) else {
                    print("找不到读卡器 \(cardReaderName)")
                    return
                }
                
                cardReaderSlot = slot
                slotStatePublisherCancellable = cardReaderSlot?.publisher(for: \.state)
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
                            dumpCardInfo()
                            processCard()
                        @unknown default:
                            fatalError("读卡器未知状态")
                        }
                    }
            }
        }
        
        RunLoop.main.run()
    }
}

extension OrzNFCReader {
    
    /// 打印读卡器相关信息
    static func dumpCardInfo() {
        if let name = cardReaderSlot?.name, let atrHexString = cardReaderSlot?.atr?.bytes.hexString,
            let maxInputLength = cardReaderSlot?.maxInputLength, let maxOutputLength = cardReaderSlot?.maxOutputLength {
            print("Reader: \(name)")
            print("Card ATR: \(atrHexString)")
            print("APDU MaxInputLength(Reader -> Card): \(maxInputLength)")
            print("APDU MaxOutputLength(Card -> Reader): \(maxOutputLength)")
        }
    }
    
    static func processCard() {
        Task {
            guard let card = cardReaderSlot?.makeSmartCard() else {
                return
            }
            
            let success = try await card.beginSession()
            if success {
                if let firewareVersion = try await card.transmit(ACR122UA9.Command.firmwareVersion.request).asciiString {
                    print("fireware version: \(firewareVersion)")
                }
                let reply = try await card.transmit(ACR122UA9.Command.piccOpParameter.request)
                if reply.first == ACR122UA9.Status.success.rawValue {
                    print("picc op params: \(reply.dropFirst().binString)")
                }
                
                
            }
            card.endSession()
        }
    }
}
