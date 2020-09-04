//
//  NFCHelper.swift
//  ICCardReader
//
//  Created by haruki on 2020/09/04.
//  Copyright © 2020 haruki. All rights reserved.
//

import Foundation
import CoreNFC
import UIKit

class NFCHelper: NSObject, ObservableObject {
    func scanning() {
        
        // 権限チェック
        guard NFCNDEFReaderSession.readingAvailable else {
            print("Error: 権限が与えられていません")
            return
        }
        
        // ICカード読み取りセッションの準備
        let session = NFCTagReaderSession(pollingOption: .iso18092, delegate: self)
        
        // 読み取り開始
        session?.alertMessage = "ICカードをiPhoneにかざしてください"
        session?.begin()
    }
}

extension NFCHelper: NFCTagReaderSessionDelegate {
    
    // 読み取り状態になった時
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        
    }
    
    // 読み取りが終了した時
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        
    }
    
    // 読み取りが成功したとき
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        // Felica以外を弾く
        let tag = tags.first!
        
        guard case .feliCa(let feliCatag) = tag else {
            session.alertMessage = "Felica以外の規格です"
            return
        }
        
        session.connect(to: tag) { (error) in
            if let error = error {
                print("Error:", error)
                return
            }
            
            let idm = feliCatag.currentIDm.map{String(format: "%.2hhx",$0)}.joined()
            let systemCode = feliCatag.currentSystemCode.map{String(format: "%.2hhx", $0)}.joined()
            let serviceCode = Data([0x09,0x0f].reversed())
            
            print("idm ", idm)
            print("systemCode ", systemCode)
            print("serviceCode ", serviceCode)
            
            feliCatag.requestService(nodeCodeList: [serviceCode]){nodes, error in
                if let error = error {
                    print("Error: ", error)
                    return
                }
                
                guard let data = nodes.first, data != Data([0xff,0xff]) else {
                    print("履歴情報がありません")
                    return
                }
                
                let block:[Data] = (0..<12).map { Data([0x80, UInt8($0)]) }
                
                feliCatag.readWithoutEncryption(serviceCodeList: [serviceCode], blockList: block) { status1, status2, dataList, error in
                    if let error = error {
                        print("Error: ", error)
                        return
                    }
                    
                    guard status1 == 0x00, status2 == 0x00 else {    // ⑧
                        print("ステータスフラグエラー: ", status1, " / ", status2)
                        return
                    }
                    
                    let firstData = dataList.first!
                    let balance = Int(firstData[10]) + Int(firstData[11]) << 8
                    print("残高 ", balance)
                    
                }
            }
        }
    }
    
    
}

