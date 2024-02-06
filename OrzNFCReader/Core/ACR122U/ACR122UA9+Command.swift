//
//  ACR122UA9+Command.swift
//  OrzNFCReader
//
//  Created by joker on 2/6/24.
//

import Foundation

extension ACR122UA9 {
    
    enum Command {
        
        /// 获取PICC的UID
        case UID
        
        /// 获取PICC的ATS
        case ATS
        
        /// 装载鉴权密钥到读卡器
        /// keyNumber: 0x00 / 0x01 密钥存储的位置，读卡器断开链接时会被清空
        /// keyBytes: 六位密钥字节码
        case loadAuthKey(keyNumber: UInt8, keyBytes: [UInt8])
        
        /// 使用读卡器中存储的密钥对MIFARE 1K/4K 卡存储区块鉴权
        /// obsolete 是否使用过时的鉴权方法
        /// blockNumber 卡片的存储区块编号
        /// keyType 密钥被使用的方式：0x60 - TypeA    0x61 - TypeB
        /// keyNumber 密钥的存储位置： 0x00 / 0x01
        case authentication(obsolete: Bool, blockNumber: UInt8, keyType: UInt8, keyNumber: UInt8)
        
        /// 读取PICC指定区块的数据
        case readBinary(blockNumber: UInt8, bytesCount: UInt8)
        
        /// 更新PICC指定区块的数据
        case updateBinary(blockNumber: UInt8, bytesCount: UInt8, bytes: [UInt8])
        
        /// 操作块数据值
        case valueBlockOp(blockNumber: UInt8, operation: UInt8, valueBytes: [UInt8])
        
        /// 读块数据值
        case readValueBlock(blockNumber: UInt8)
        
        /// 恢复块数据值
        case restoreValueBlock(sourceBlock: UInt8, targetBlock: UInt8)
        
        /// 直接传输
        case directTransmit(payload: [UInt8])
        
        /// LED和蜂鸣器控制
        case ledAndBuzzer(ledStatus: UInt8, blinkDuration: [UInt8])
        
        /// 获取读写器固件版本, ASCII字符串
        case firmwareVersion
        
        /// 获取PICC操作参数
        /// PICC 操作参数(默认值 = FFh)
        case piccOpParameter
        
        /// 设置PICC操作参数
        /// bit7 - 自动 PICC 轮询  1: 启用  0:停用
        /// bit6 - 自动ATS生成，每次激活 ISO 14443-4 A 类标签都发送ATS请求   1: 启用  0:停用
        /// bit5 - 轮询时间间隔  1: 250ms  0: 500ms
        /// bit4 - FeliCa 424K   1: 检测 0:跳过
        /// bit3 - FeliCa 212K   1: 检测 0:跳过
        /// bit2 - Topaz             1: 检测 0:跳过
        /// bit1 - ISO 14443 Type B  1: 检测 0:跳过
        /// bit0 - ISO 14443 A 类，要检测 Mifare 标签，必须首先禁用自动 ATS 生成  1: 检测 0:跳过
        case setPiccOpParameter(UInt8)
        
        /// 设置超时参数
        /// 0x00 - 不检查超时
        /// 0x01~0xFE - 以5秒为单位，进行超时设置，即 timeout = n * 5 秒
        /// 0xFF - 一直等待，超时时长无限
        case setTimeoutParameter(UInt8)
        
        /// 设置卡片检查到时，蜂鸣器是否响
        case buzzer(isOn: Bool)
        
        /// 设置天线是否开启
        case antenna(isOn: Bool)
        
        /// ATS of IOS14443-4 Type A Tag
        case iso144434AATS
        
        /// 获取当前设置
        case settings
        
        /// Get Challenge
        case challenge
        
        /// 自定义命令
        case custom(bytes: [UInt8])
    }
}

extension ACR122UA9.Command {
    
    /// 字节定义
    var bytes: [UInt8] {
        switch self {
        case .UID:
            return [0xFF, 0xCA, 0x00, 0x00, 0x00]
        case .ATS:
            return [0xFF, 0xCA, 0x01, 0x00, 0x00]
        case .loadAuthKey(let keyNumber, let keyBytes):
            return [0xFF, 0x82, 0x00, keyNumber, 0x06] + keyBytes
        case .authentication(let obsolete, let blockNumber, let keyType, let keyNumber):
            if obsolete {
                return [0xFF, 0x88, 0x00, blockNumber, keyType, keyNumber]
            } else {
                return [0xFF, 0x86, 0x00, 0x00, 0x05, 0x01, 0x00, blockNumber, keyType, keyNumber]
            }
        case .readBinary(let blockNumber, let bytesCount):
            return [0xFF, 0xB0, 0x00, blockNumber, bytesCount]
        case .updateBinary(let blockNumber, let bytesCount, let bytes):
            return [0xFF, 0xD6, 0x00, blockNumber, bytesCount] + bytes
        case .valueBlockOp(let blockNumber, let operation, let valueBytes):
            return [0xFF, 0xD7, 0x00, blockNumber, 0x05, operation] + valueBytes
        case .readValueBlock(let blockNumber):
            return [0xFF, 0xB1, 0x00, blockNumber, 0x04]
        case .restoreValueBlock(let sourceBlock, let targetBlock):
            return [0xFF, 0xD7, 0x00, sourceBlock, 0x02, 0x03, targetBlock]
        case .directTransmit(let payload):
            return [0xFF, 0x00, 0x00, 0x00, UInt8(payload.count)] + payload
        case .ledAndBuzzer(let ledStatus, let blinkDurationBytes):
            return [0xFF, 0x00, 0x40, ledStatus, 0x04] + blinkDurationBytes
        case .firmwareVersion:
            return [0xFF, 0x00, 0x48, 0x00, 0x00]
        case .piccOpParameter:
            return [0xFF, 0x00, 0x50, 0x00, 0x00]
        case .setPiccOpParameter(let picc):
            return [0xFF, 0x00, 0x51, picc, 0x00]
        case .setTimeoutParameter(let timeout):
            return [0xFF, 0x00, 0x41, timeout, 0x00]
        case .buzzer(let isOn):
            return [0xFF, 0x00, 0x52, isOn ? 0xFF : 0x00, 0x00]
        case .antenna(let isOn):
            return [0xFF, 0x00, 0x00, 0x00, 0x04, 0xD4, 0x32, 0x01, isOn ? 0x01 : 0x00]
        case .iso144434AATS:
            return [0xFF, 0xCA, 0x00, 0x00, 0x01]
        case .challenge:
            return [0x00, 0x84, 0x00, 0x00, 0x08]
        case .settings:
            return [0xFF, 0x00, 0x00, 0x00, 0x02, 0xD4, 0x04]
        case .custom(let bytes):
            return bytes
        }
    }
}
