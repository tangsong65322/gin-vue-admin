
import Foundation
import CryptoSwift
import Security
import CommonCrypto
// UTS内置对象的引用
import DCloudUTSFoundation
enum OutputLength: Int {
    case LENGTH_16 = 8  // 8 bytes = 16 hex chars
    case LENGTH_32 = 16 // 16 bytes = 32 hex chars
    case LENGTH_64 = 32 // 32 bytes = 64 hex chars
}


struct RSARandomKey {
    let publicKey: String
    let privateKey: String
}

enum RSAError: Error {
    case keyExtractionFailed

    case invalidKeyFormat
    case invalidInput
	case keyGenerationFailed(status: OSStatus)
	case publicKeyConversionFailed
	case privateKeyConversionFailed
	
	case keyCreationFailed
	case encryptionFailed
	case decryptionFailed
	case dataConversionFailed
	case base64DecodingFailed
}

// 生成指定长度的密钥，类似于Android版本
func generateKey(key: String, keySize: Int = 16) -> [UInt8] {
    let keyBytes = Array(key.utf8)
    var paddedKey = [UInt8](repeating: 0, count: keySize)
    
    if keyBytes.count < keySize {
        // 不足时用0填充
        paddedKey.replaceSubrange(0..<keyBytes.count, with: keyBytes)
    } else {
        // 过长时截断
        paddedKey.replaceSubrange(0..<keySize, with: keyBytes[0..<keySize])
    }
    
    return paddedKey
}

// 生成指定长度的密钥，处理ByteArray输入，类似于Android版本的generateDesKey2
func generateKey2(key: [UInt8], keySize: Int = 16) -> [UInt8] {
    var paddedKey = [UInt8](repeating: 0, count: keySize)
    
    if key.count < keySize {
        // 不足时用0填充
        paddedKey.replaceSubrange(0..<key.count, with: key)
    } else {
        // 过长时截断
        paddedKey.replaceSubrange(0..<keySize, with: key[0..<keySize])
    }
    
    return paddedKey
}

//
//  MZRSA.swift
//  TDSwiftTemplate
//
//  Created by 曾龙 on 2021/12/1.
//
public struct MZRSA {
    
    //MARK:-  encrypt or decrypt by SecKey String
    
    /// 使用私钥字符串加密Data
    /// - Parameters:
    ///   - data: 需加密的Data
    ///   - privateKey: 私钥字符串
    /// - Returns: 加密后Data
    public static func encryptData(_ data: Data, privateKey: String) -> Data? {
        let secKey = addPrivateKey(privateKey)
        if secKey == nil {
            return nil
        }
        return encrypt(data, with: secKey!, and: true)
    }
    
    /// 使用私钥字符串加密String
    /// - Parameters:
    ///   - string: 需加密的String
    ///   - privateKey: 私钥字符串
    /// - Returns: 加密后String
    public static func encryptString(_ string: String, privateKey: String) -> String? {
        guard let data = encryptData(string.data(using: String.Encoding.utf8)!, privateKey: privateKey) else {
            return nil
        }
        return base64_encode_data(data)
    }
    
    /// 使用私钥字符串解密Data
    /// - Parameters:
    ///   - data: 需解密的Data
    ///   - privateKey: 私钥字符串
    /// - Returns: 解密后Data
    public static func decryptData(_ data: Data, privateKey: String) -> Data? {
        let secKey = addPrivateKey(privateKey)
        if secKey == nil {
            return nil
        }
        return decrypt(data, with: secKey!)
    }
    
    /// 使用私钥字符串解密String
    /// - Parameters:
    ///   - string: 需解密的String
    ///   - privateKey: 私钥字符串
    /// - Returns: 解密后String
    public static func decryptString(_ string: String, privateKey: String) -> String? {
        var data = base64_decode(string)
        data = decryptData(data!, privateKey: privateKey)
        if data == nil {
            return nil
        }
        return String.init(data: data!, encoding: String.Encoding.utf8)
    }
    
    /// 使用公钥字符串加密Data
    /// - Parameters:
    ///   - data: 需加密的Data
    ///   - publicKey: 公钥字符串
    /// - Returns: 加密后Data
    public static func encryptData(_ data: Data, publicKey: String) -> Data? {
        let secKey = addPublicKey(publicKey)
        if secKey == nil {
            return nil
        }
        return encrypt(data, with: secKey!, and: false)
    }
    
    /// 使用公钥字符串加密String
    /// - Parameters:
    ///   - string: 需加密的String
    ///   - publicKey: 公钥字符串
    /// - Returns: 加密后String
    public static func encryptString(_ string: String, publicKey: String) -> String? {
        guard let data = encryptData(string.data(using: String.Encoding.utf8)!, publicKey: publicKey) else {
            return nil
        }
        return base64_encode_data(data)
    }
    
    /// 使用公钥字符串解密Data
    /// - Parameters:
    ///   - data: 需解密的Data
    ///   - publicKey: 公钥字符串
    /// - Returns: 解密后Data
    public static func decryptData(_ data: Data, publicKey: String) -> Data? {
        let secKey = addPublicKey(publicKey)
        if secKey == nil {
            return nil
        }
        return decrypt(data, with: secKey!)
    }
    
    /// 使用公钥字符串解密String
    /// - Parameters:
    ///   - string: 需解密的String
    ///   - publicKey: 公钥字符串
    /// - Returns: 解密后String
    public static func decryptString(_ string: String, publicKey: String) -> String? {
        var data = base64_decode(string)
        data = decryptData(data!, publicKey: publicKey)
        if data == nil {
            return nil
        }
        return String.init(data: data!, encoding: String.Encoding.utf8)
    }
    
    //MARK:- encrypt or decrypt by SecKey data
    
    /// 使用私钥Data加密Data
    /// - Parameters:
    ///   - data: 需加密的Data
    ///   - privateKeyData: 私钥Data
    /// - Returns: 加密后的Data
    public static func encryptData(_ data: Data, privateKeyData: Data) -> Data? {
        let secKey = addPrivateKey(privateKeyData)
        if secKey == nil {
            return nil
        }
        return encrypt(data, with: secKey!, and: true)
    }
    
    /// 使用私钥Data加密String
    /// - Parameters:
    ///   - string: 需加密的String
    ///   - privateKeyData: 私钥Data
    /// - Returns: 加密后的String
    public static func encryptString(_ string: String, privateKeyData: Data) -> String? {
        guard let data = encryptData(string.data(using: String.Encoding.utf8)!, privateKeyData: privateKeyData) else {
            return nil
        }
        return base64_encode_data(data)
    }
    
    /// 用私钥Data解密Data
    /// - Parameters:
    ///   - data: 需解密的Data
    ///   - privateKeyData: 私钥Data
    /// - Returns: 解密后的Data
    public static func decryptData(_ data: Data, privateKeyData: Data) -> Data? {
        let secKey = addPrivateKey(privateKeyData)
        if secKey == nil {
            return nil
        }
        return decrypt(data, with: secKey!)
    }
    
    /// 用私钥Data解密String
    /// - Parameters:
    ///   - string: 需解密的String
    ///   - privateKeyData: 私钥Data
    /// - Returns: 解密后的String
    public static func decryptString(_ string: String, privateKeyData: Data) -> String? {
        var data = base64_decode(string)
        data = decryptData(data!, privateKeyData: privateKeyData)
        if data == nil {
            return nil
        }
        return String.init(data: data!, encoding: String.Encoding.utf8)
    }
    
    /// 使用公钥Data加密Data
    /// - Parameters:
    ///   - data: 需加密的Data
    ///   - publicKeyData: 公钥Data
    /// - Returns: 加密后Data
    public static func encryptData(_ data: Data, publicKeyData: Data) -> Data? {
        let secKey = addPublicKey(publicKeyData)
        if secKey == nil {
            return nil
        }
        return encrypt(data, with: secKey!, and: false)
    }
    
    /// 使用公钥Data加密String
    /// - Parameters:
    ///   - string: 需加密的String
    ///   - publicKeyData: 公钥Data
    /// - Returns: 加密后String
    public static func encryptString(_ string: String, publicKeyData: Data) -> String? {
        guard let data = encryptData(string.data(using: String.Encoding.utf8)!, publicKeyData: publicKeyData) else {
            return nil
        }
        return base64_encode_data(data)
    }
    
    /// 使用公钥Data解密Data
    /// - Parameters:
    ///   - data: 需解密的Data
    ///   - publicKeyData: 公钥Data
    /// - Returns: 解密后Data
    public static func decryptData(_ data: Data, publicKeyData: Data) -> Data? {
        let secKey = addPublicKey(publicKeyData)
        if secKey == nil {
            return nil
        }
        return decrypt(data, with: secKey!)
    }
    
    /// 使用公钥Data解密String
    /// - Parameters:
    ///   - string: 需解密的String
    ///   - publicKeyData: 公钥Data
    /// - Returns: 解密后String
    public static func decryptString(_ string: String, publicKeyData: Data) -> String? {
        var data = base64_decode(string)
        data = decryptData(data!, publicKeyData: publicKeyData)
        if data == nil {
            return nil
        }
        return String.init(data: data!, encoding: String.Encoding.utf8)
    }
    
    //MARK:- encrypt or decrypt by SecKey path
    
    
    /// 使用私钥证书路径加密Data
    /// - Parameters:
    ///   - data: 需加密的Data
    ///   - privateKeyPath: 私钥证书路径
    /// - Returns: 加密后Data
    public static func encryptData(_ data: Data, privateKeyPath: String) -> Data? {
        let secKey = loadPrivateKey(privateKeyPath)
        if secKey == nil {
            return nil
        }
        return encrypt(data, with: secKey!, and: true)
    }
    
    /// 使用私钥证书路径加密String
    /// - Parameters:
    ///   - string: 需加密的String
    ///   - privateKeyPath: 私钥证书路径
    /// - Returns: 加密后String
    public static func encryptString(_ string: String, privateKeyPath: String) -> String? {
        guard let data = encryptData(string.data(using: String.Encoding.utf8)!, privateKeyPath: privateKeyPath) else {
            return nil
        }
        return base64_encode_data(data)
    }
    
    /// 使用私钥证书路径解密Data
    /// - Parameters:
    ///   - data: 需解密的Data
    ///   - privateKeyPath: 私钥证书路径
    /// - Returns: 解密后Data
    public static func decryptData(_ data: Data, privateKeyPath: String) -> Data? {
        let secKey = loadPrivateKey(privateKeyPath)
        if secKey == nil {
            return nil
        }
        return decrypt(data, with: secKey!)
    }
    
    /// 使用私钥证书路径解密String
    /// - Parameters:
    ///   - string: 需解密的String
    ///   - privateKeyPath: 私钥证书路径
    /// - Returns: 解密后String
    public static func decryptString(_ string: String, privateKeyPath: String) -> String? {
        var data = base64_decode(string)
        data = decryptData(data!, privateKeyPath: privateKeyPath)
        if data == nil {
            return nil
        }
        return String.init(data: data!, encoding: String.Encoding.utf8)
    }
    
    /// 使用公钥证书路径加密Data
    /// - Parameters:
    ///   - data: 需加密的Data
    ///   - publicKeyPath: 公钥证书路径
    /// - Returns: 加密后Data
    public static func encryptData(_ data: Data, publicKeyPath: String) -> Data? {
        let secKey = loadPublicKey(publicKeyPath)
        if secKey == nil {
            return nil
        }
        return encrypt(data, with: secKey!, and: false)
    }
    
    /// 使用公钥证书路径加密String
    /// - Parameters:
    ///   - string: 需加密的String
    ///   - publicKeyPath: 公钥证书路径
    /// - Returns: 加密后String
    public static func encryptString(_ string: String, publicKeyPath: String) -> String? {
        guard let data = encryptData(string.data(using: String.Encoding.utf8)!, publicKeyPath: publicKeyPath) else {
            return nil
        }
        return base64_encode_data(data)
    }
    
    /// 使用公钥证书路径解密Data
    /// - Parameters:
    ///   - data: 需解密的Data
    ///   - publicKeyPath: 公钥证书路径
    /// - Returns: 解密后Data
    public static func decryptData(_ data: Data, publicKeyPath: String) -> Data? {
        let secKey = loadPublicKey(publicKeyPath)
        if secKey == nil {
            return nil
        }
        return decrypt(data, with: secKey!)
    }
    
    /// 使用公钥证书路径解密String
    /// - Parameters:
    ///   - string: 需解密的String
    ///   - publicKeyPath: 公钥证书路径
    /// - Returns: 解密后String
    public static func decryptString(_ string: String, publicKeyPath: String) -> String? {
        var data = base64_decode(string)
        data = decryptData(data!, publicKeyPath: publicKeyPath)
        if data == nil {
            return nil
        }
        return String.init(data: data!, encoding: String.Encoding.utf8)
    }
    
    
    //MARK:- OTHER
    
    private static func base64_encode_data(_ data: Data) -> String? {
        let newData = data.base64EncodedData(options: Data.Base64EncodingOptions.lineLength64Characters)
        return String.init(data: newData, encoding: String.Encoding.utf8)
    }
    
    private static func base64_decode(_ string: String) -> Data? {
        return Data.init(base64Encoded: string, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
    }
    
    private static func stripPublicKeyHeader(_ d_key: Data?) -> Data? {
        guard let dKey = d_key else {
            return nil
        }
        let len = dKey.count
        if len == 0 {
            return nil
        }
        
        var cKey = dataToBytes(dKey)
        var index = 0
        
        if cKey[index] != 0x30 {
            return nil
        }
        index += 1
        
        if cKey[index] > 0x80 {
            index += Int(cKey[index]) - 0x80 + 1
        } else {
            index += 1
        }
        
        let swqiod:[CUnsignedChar] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
                                      0x01, 0x05, 0x00]
        if (memcmp(&cKey[index], swqiod, 15) == 1) {
            return nil
        }
        
        index += 15
        
        if cKey[index] != 0x03 {
            return nil
        }
        index += 1
        
        if cKey[index] > 0x80 {
            index += Int(cKey[index]) - 0x80 + 1
        } else {
            index += 1
        }
        
        if cKey[index] != Unicode.Scalar.init("\0").value {
            return nil
        }
        
        index += 1

        return Data.init(cKey).advanced(by: index)
    }
    
    private static func stripPrivateKeyHeader(_ d_key: Data?) -> Data? {
        guard let dKey = d_key else {
            return nil
        }
        let len = dKey.count
        if len == 0 {
            return nil
        }
        
        var cKey = dataToBytes(dKey)
        var index = 22
        
        if cKey[index] != 0x04 {
            return nil
        }
        index += 1
        
        var cLen = Int(cKey[index])
        index += 1
        let det = cLen & 0x80
        if det == 0 {
            cLen = cLen & 0x7f
        } else {
            var byteCount = Int(cLen & 0x7f)
            if Int(byteCount) + index > len {
                return nil
            }
            var accum = 0
            var ptr = withUnsafePointer(to: &cKey[index]) { $0 }
            index += Int(byteCount)
            while byteCount > 0 {
                accum = (accum << 8) + Int(ptr.pointee)
                ptr = ptr.advanced(by: 1)
                byteCount -= 1
            }
            cLen = accum
        }
        
        return dKey.subdata(in: Range.init(_NSRange.init(location: index, length: Int(cLen)))!)
    }
    
    /// 公钥字符串转SecKey
    /// - Parameter key: 公钥字符串
    /// - Returns: SecKey
    private static func addPublicKey(_ key: String) -> SecKey? {
        var newKey = key
        let spos = newKey.range(of: "-----BEGIN PUBLIC KEY-----")
        let epos = newKey.range(of: "-----END PUBLIC KEY-----")
        if spos != nil && epos != nil {
            newKey = String(newKey[spos!.upperBound..<epos!.lowerBound])
        }
        newKey = newKey.replacingOccurrences(of: "\r", with: "")
        newKey = newKey.replacingOccurrences(of: "\n", with: "")
        newKey = newKey.replacingOccurrences(of: "\t", with: "")
        newKey = newKey.replacingOccurrences(of: " ", with: "")
        
        var data = base64_decode(newKey)
        data = stripPublicKeyHeader(data)
        if data == nil {
            return nil
        }
        
        return addPublicKey(data!)
    }
    
    public static func addPublicKey(_ data: Data) -> SecKey? {
        let tag = "RSAUtil_PubKey"
        let d_tag = tag.data(using: String.Encoding.utf8)
        
        var publicKey = Dictionary<String, Any>.init()
        publicKey[kSecClass as String] = kSecClassKey
        publicKey[kSecAttrKeyType as String] = kSecAttrKeyTypeRSA
        publicKey[kSecAttrApplicationTag as String] = d_tag
        SecItemDelete(publicKey as CFDictionary)

        publicKey[kSecValueData as String] = data
        publicKey[kSecAttrKeyClass as String] = kSecAttrKeyClassPublic
        publicKey[kSecReturnPersistentRef as String] = true

        var status = SecItemAdd(publicKey as CFDictionary, nil)

        if status != noErr && status != errSecDuplicateItem {
            return nil
        }

        publicKey.removeValue(forKey: kSecValueData as String)
        publicKey.removeValue(forKey: kSecReturnPersistentRef as String)
        publicKey[kSecReturnRef as String] = NSNumber(value: true)
        publicKey[kSecAttrKeyType as String] = kSecAttrKeyTypeRSA

        var keyRef: CFTypeRef?
        status = SecItemCopyMatching(publicKey as CFDictionary, &keyRef)
        if status != noErr {
            return nil
        }
        return (keyRef as! SecKey)
    }
    
    /// 私钥字符串转SecKey
    /// - Parameter key: 私钥字符串        /// - Returns: SecKey
    private static func addPrivateKey(_ key: String) -> SecKey? {
        var newKey = key
        var spos: Range<String.Index>?
        var epos: Range<String.Index>?
        spos =  newKey.range(of: "-----BEGIN RSA PRIVATE KEY-----")
        if spos != nil {
            epos = newKey.range(of: "-----END RSA PRIVATE KEY-----")
        } else {
            spos = newKey.range(of: "-----BEGIN PRIVATE KEY-----")
            epos = newKey.range(of: "-----END PRIVATE KEY-----")
        }
        if spos != nil && epos != nil {
            newKey = String(newKey[spos!.upperBound..<epos!.lowerBound])
        }
        newKey = newKey.replacingOccurrences(of: "\r", with: "")
        newKey = newKey.replacingOccurrences(of: "\n", with: "")
        newKey = newKey.replacingOccurrences(of: "\t", with: "")
        newKey = newKey.replacingOccurrences(of: " ", with: "")
        
        var data = base64_decode(newKey)
        data = stripPrivateKeyHeader(data)
        if data == nil {
            return nil
        }
        
        return addPrivateKey(data!)
    }
    
    private static func addPrivateKey(_ data: Data) -> SecKey? {
        let tag = "RSAUtil_PrivKey"
        let d_tag = tag.data(using: String.Encoding.utf8)
        
        var privateKey = Dictionary<CFString, Any>.init()
        privateKey[kSecClass] = kSecClassKey
        privateKey[kSecAttrKeyType] = kSecAttrKeyTypeRSA
        privateKey[kSecAttrApplicationTag] = d_tag
        SecItemDelete(privateKey as CFDictionary)
        
        privateKey[kSecValueData] = data
        privateKey[kSecAttrKeyClass] = kSecAttrKeyClassPrivate
        privateKey[kSecReturnPersistentRef] = true
        
        var persistKey: CFTypeRef?
        var status = SecItemAdd(privateKey as CFDictionary, &persistKey)
        
        if status != noErr && status != errSecDuplicateItem {
            return nil
        }
        
        privateKey.removeValue(forKey: kSecValueData)
        privateKey.removeValue(forKey: kSecReturnPersistentRef)
        privateKey[kSecReturnRef] = true
        privateKey[kSecAttrKeyType] = kSecAttrKeyTypeRSA
        
        var keyRef: CFTypeRef?
        status = SecItemCopyMatching(privateKey as CFDictionary, &keyRef)
        if status != noErr {
            return nil
        }
        return (keyRef as! SecKey)
    }
    
    private static func encrypt(_ data: Data, with secKey: SecKey, and isSign: Bool) -> Data? {
        var srcbuf = dataToBytes(data)
        let srclen = data.count
        
        let block_size = SecKeyGetBlockSize(secKey) * MemoryLayout<UInt8>.size
        var outbuf = [UInt8](repeating: 0, count: block_size)
        let src_block_size = block_size - 11
        
        var ret: Data? = Data.init()
        var index = 0
        while index < srclen {
            var data_len = srclen - index
            if data_len > src_block_size {
                data_len = src_block_size
            }
            
            var outlen = block_size
            var status = noErr
            
            let ptr = withUnsafePointer(to: &srcbuf[index]) { $0 }
            if isSign {
                status = SecKeyRawSign(secKey, SecPadding.PKCS1, ptr, data_len, &outbuf, &outlen)
            } else {
                status = SecKeyEncrypt(secKey, SecPadding.PKCS1, ptr, data_len, &outbuf, &outlen)
            }
            if status != 0 {
                ret = nil
                break
            } else {
                ret!.append(contentsOf: outbuf[0..<outlen])
            }
            
            index += src_block_size
        }
        
        return ret
    }
    
    private static func decrypt(_ data: Data, with secKey: SecKey) -> Data? {
        var srcbuf = dataToBytes(data)
        let srclen = data.count
        
        let block_size = SecKeyGetBlockSize(secKey) * MemoryLayout<UInt8>.size
        var outbuf = [UInt8](repeating: 0, count: block_size)
        let src_block_size = block_size
        
        var ret: Data? = Data.init()
        var index = 0
        while index < srclen {
            var data_len = srclen - index
            if data_len > src_block_size {
                data_len = src_block_size
            }
            
            var outlen = block_size
            var status = noErr
            
            let ptr = withUnsafePointer(to: &srcbuf[index]) { $0 }
            status = SecKeyDecrypt(secKey, SecPadding.init(rawValue: 0), ptr, data_len, &outbuf, &outlen)
            
            if status != 0 {
                ret = nil
                break
            } else {
                var idxFirstZero = -1
                var idxNextZero = Int(outlen)
                for i in 0..<outlen {
                    if outbuf[i] == 0 {
                        if idxFirstZero < 0 {
                            idxFirstZero = i
                        } else {
                            idxNextZero = i
                            break
                        }
                    }
                }
                ret?.append(contentsOf: outbuf[idxFirstZero+1..<idxNextZero])
            }
            
            index += src_block_size
        }
        
        return ret
    }
    
    /// 从.der证书获取公钥
    /// - Parameter der: .der证书路径
    /// - Returns: 公钥
    private static func loadPublicKey(_ path: String) -> SecKey? {
        let data: Data;
        do {
            data = try Data.init(contentsOf: URL.init(fileURLWithPath: path))
        } catch {
            return nil
        }
        
        guard let cert = SecCertificateCreateWithData(nil, data as CFData) else {
            return nil
        }
        let key: SecKey?
        var trust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        if SecTrustCreateWithCertificates(cert, policy, &trust) == noErr {
            var result = SecTrustResultType.invalid
            if trust != nil {
                if SecTrustEvaluate(trust!, &result) == noErr {
                    key = SecTrustCopyPublicKey(trust!)
                    return key
                }
            }
        }
        return nil
    }
    
    /// 从.p12证书获取私钥
    /// - Parameters:
    ///   - path: .p12证书路径
    ///   - password: ,p12证书密码
    /// - Returns: 私钥
    private static func loadPrivateKey(_ path: String, with password: String = "") -> SecKey? {
        let data: Data;
        do {
            data = try Data.init(contentsOf: URL.init(fileURLWithPath: path))
        } catch {
            return nil
        }
        
        var key: SecKey?
        let options = NSMutableDictionary.init()
        options[kSecImportExportPassphrase as String] = password
        var items: CFArray?
        var securityError = SecPKCS12Import(data as CFData, options, &items)
        if securityError == noErr && CFArrayGetCount(items) > 0 {
            let identityDict = CFArrayGetValueAtIndex(items, 0)
            let appKey = Unmanaged.passUnretained(kSecImportItemIdentity).toOpaque()
            let identityApp = CFDictionaryGetValue((identityDict as! CFDictionary), appKey)
            securityError = SecIdentityCopyPrivateKey(identityApp as! SecIdentity, &key)
            if securityError == noErr {
                return key
            }
        }
        return nil
    }
    
    /// Data转Byte(UInt8)数组
    /// - Parameter data: Data
    /// - Returns: Byte(UInt8)数组
    private static func dataToBytes(_ data: Data) -> [UInt8] {
        let string = dataToHex(data)
        var start = string.startIndex
        return stride(from: 0, to: string.count, by: 2).compactMap { _ in
            let end = string.index(after: start)
            defer {start = string.index(after: end)}
            return UInt8(string[start...end], radix: 16)
        }
    }
    
    /// Data转16进制字符串
    /// - Parameter data: Data
    /// - Returns: 16进制字符串
    private static func dataToHex(_ data: Data) -> String {
        let bytes = [UInt8](data)
        var hex = ""
        for index in 0..<data.count {
            let newHex = String(format: "%x", bytes[index]&0xff)
            if newHex.count == 1 {
                hex = String(format: "%@0%@", hex, newHex)
            } else {
                hex += newHex
            }
        }
        return hex
    }
}


// RC4 加密和解密
func rc4(data: Data, key: String) -> Data {
    let keyBytes = [UInt8](key.utf8)
    var s = Array(0...255)  // S-box
    var j = 0

    // 初始化 S-box
    for i in 0..<256 {
		j = (j + s[i] + Int(keyBytes[i % keyBytes.count])) & 0xFF
        s.swapAt(i, j)
    }

    var i = 0
    j = 0
    var output = Data()

    // 加密/解密
    for byte in data {
        i = (i + 1) & 0xFF
        j = (j + s[i]) & 0xFF
        s.swapAt(i, j)
        let k = s[(s[i] + s[j]) & 0xFF]
        output.append(byte ^ UInt8(k))
    }

    return output
}

// 字符串转十六进制
func stringToHex(_ data: Data) -> String {
    return data.map { String(format: "%02x", $0) }.joined()
}

// 十六进制转 Data
func hexToData(_ hex: String) -> Data? {
    var data = Data()
    var tempHex = hex
    while tempHex.count > 0 {
        let c = tempHex.prefix(2)
        tempHex.removeFirst(2)
        if let byte = UInt8(c, radix: 16) {
            data.append(byte)
        } else {
            return nil
        }
    }
    return data
}

// RC4 加密
func rc4Encrypt2(data: String, key: String) -> String {
    let dataBytes = Data(data.utf8)
    let encryptedData = rc4(data: dataBytes, key: key)
    return stringToHex(encryptedData)
}

// RC4 解密
func rc4Decrypt2(encryptedHex: String, key: String) -> String {
    guard let encryptedData = hexToData(encryptedHex) else { return "" }
    let decryptedData = rc4(data: encryptedData, key: key)
    return String(data: decryptedData, encoding: .utf8) ?? ""
}

class UniversalCryptoHelper {
    
    // MD5 Encryption
    static func md5(input: String) -> String {
        let md5Hash = input.md5();
		return md5Hash;
    }
    
    // Base64 Encoding and Decoding
    static func base64Encode(input: String) -> String {
        let data = input.data(using: .utf8)!;
        return data.base64EncodedString();
    }
    
    static func base64Decode(input: String) -> String {
       if let data = Data(base64Encoded: input) {
		   if let decryptedString = String(data: data, encoding: .utf8) {
		       return decryptedString
		   } else {
		       return ""  // 或者处理解包失败的情况
		   }
	   }
	   return ""
    }
    
    // HMAC with SHA-256
    static func hmacSha256(key: String, data: String) -> String {
       let hmac = try! HMAC(key: Array(key.utf8), variant: .sha256)
	   let hash = try! hmac.authenticate(Array(data.utf8))
	   return hash.toHexString()
    }
	
	// HMAC with SHA-512
	static func hmacSha512(key: String, data: String) -> String {
	   let hmac = try! HMAC(key: Array(key.utf8), variant: .sha512)
	   let hash = try! hmac.authenticate(Array(data.utf8))
	   return hash.toHexString()
	}
    
    // SHA-1 and SHA-256 Hashing
    static func sha1(input: String) -> String {
        let sha1Hash = input.sha1()
        return sha1Hash
    }
    
    static func sha256(input: String) -> String {
        let sha256Hash = input.sha256()
        return sha256Hash
    }
	
	static func sha512(input: String) -> String {
	    let sha512Hash = input.sha512()
	    return sha512Hash
	}
    

    // AES Encryption and Decryption
    static func aesEncrypt(input: String, key: String, mode: String = "ECB", iv: String? = nil,keySize:Int=16) -> String {
      
	   do {
		   let keyBytes = generateKey(key: key, keySize: keySize)
		   
		   var aes: AES
		   
		   switch mode.lowercased() {
		   case "ecb":
			   aes = try AES(key: keyBytes, blockMode: ECB(), padding: .pkcs7)
		   case "cbc":
			   guard let iv = iv else { return "" }
			   let ivBytes = generateKey(key: iv, keySize: 16)
			   aes = try AES(key: keyBytes, blockMode: CBC(iv: ivBytes), padding: .pkcs7)
		   default:
			   return "" // 如果模式不支持，返回空字符串
		   }
		   
		   let encryptedBytes = try aes.encrypt(input.bytes)
		   let encryptedData = Data(encryptedBytes)
		   return encryptedData.base64EncodedString()
	   } catch {
		   console.log("Encryption failed: \(error)")
		   return "" // 如果出现错误，返回空字符串
	   }
    }
    
    static func aesDecrypt(input: String, key: String, mode: String = "ECB", iv: String? = nil,keySize:Int=16) -> String {
       do {
		   let keyBytes = generateKey(key: key, keySize: keySize)
		  
		   
		   var aes: AES
		   
		   switch mode.lowercased() {
		   case "ecb":
			   aes = try AES(key: keyBytes, blockMode: ECB(), padding: .pkcs7)
		   case "cbc":
			   guard let iv = iv else { return "" }
			   let ivBytes = generateKey(key: iv, keySize: 16)
			   aes = try AES(key: keyBytes, blockMode: CBC(iv: ivBytes), padding: .pkcs7)
		   default:
			   return "" // 如果模式不支持，返回空字符串
		   }
		   
		   let encryptedData = Data(base64Encoded: input)!
		   let decryptedBytes = try aes.decrypt(encryptedData.bytes)
		   if let decryptedString = String(bytes: decryptedBytes, encoding: .utf8) {
			   return decryptedString
		   } else {
			   return "" // 如果解密后的数据无法转换为字符串，返回空字符串
		   }
	   } catch {
		   console.log("Decryption failed: \(error)")
		   return "" // 如果出现错误，返回空字符串
	   }
    }
    
    // AES Encryption for ByteArray input/output, similar to Android aesEncrypt2
    static func aesEncrypt2(input: Data, key: Data, mode: String = "ECB", iv: Data? = nil, keySize: Int = 16) -> Data {
        do {
            let keyBytes = generateKey2(key: [UInt8](key), keySize: keySize)
            
            var aes: AES
            
            switch mode.lowercased() {
            case "ecb":
                aes = try AES(key: keyBytes, blockMode: ECB(), padding: .pkcs7)
            case "cbc":
                let ivBytes: [UInt8]
                if let iv = iv {
                    ivBytes = generateKey2(key: [UInt8](iv), keySize: 16)
                } else {
                    ivBytes = [UInt8](repeating: 0, count: 16)
                }
                aes = try AES(key: keyBytes, blockMode: CBC(iv: ivBytes), padding: .pkcs7)
            default:
                return Data() // 如果模式不支持，返回空数组
            }
            
            let encryptedBytes = try aes.encrypt([UInt8](input))
            return Data(encryptedBytes)
        } catch {
            console.log("Encryption failed: \(error)")
            return Data() // 如果出现错误，返回空数组
        }
    }
    
    // AES Decryption for ByteArray input/output, similar to Android aesDecrypt2
    static func aesDecrypt2(input: Data, key: Data, mode: String = "ECB", iv: Data? = nil, keySize: Int = 16) -> Data {
        do {
            let keyBytes = generateKey2(key: [UInt8](key), keySize: keySize)
            
            var aes: AES
            
            switch mode.lowercased() {
            case "ecb":
                aes = try AES(key: keyBytes, blockMode: ECB(), padding: .pkcs7)
            case "cbc":
                let ivBytes: [UInt8]
                if let iv = iv {
                    ivBytes = generateKey2(key: [UInt8](iv), keySize: 16)
                } else {
                    ivBytes = [UInt8](repeating: 0, count: 16)
                }
                aes = try AES(key: keyBytes, blockMode: CBC(iv: ivBytes), padding: .pkcs7)
            default:
                return Data() // 如果模式不支持，返回空数组
            }
            
            let decryptedBytes = try aes.decrypt([UInt8](input))
            return Data(decryptedBytes)
        } catch {
            console.log("Decryption failed: \(error)")
            return Data() // 如果出现错误，返回空数组
        }
    }
    
  
    // DES Encryption and Decryption
    static func desEncrypt(input: String, key: String, mode: String = "ECB", iv: String? = nil) -> String {
       guard key.count == kCCKeySizeDES else {
		   console.log("Key length must be 8 bytes.")
		   return ""
	   }
	   
	   let data = input.data(using: .utf8)!
	   let keyData = key.data(using: .utf8)!
	   let keyBytes = [UInt8](keyData)
	   
	   var options: CCOptions = CCOptions(kCCOptionPKCS7Padding)
	   var ivBytes: [UInt8]?
	   console.log(mode.lowercased() ,iv,"---")
	   if mode.lowercased() == "ecb" {
		   options |= CCOptions(kCCOptionECBMode)
	   } else if mode.lowercased() == "cbc", let iv = iv {
		   ivBytes = [UInt8](iv.data(using: .utf8)!)
	   } else {
		   console.log("Invalid mode or missing IV for CBC.")
		   return ""
	   }
	   
	   var buffer = [UInt8](repeating: 0, count: data.count + kCCBlockSizeDES)
	   var bufferLength = 0
	   
	   let cryptStatus = CCCrypt(
		   CCOperation(kCCEncrypt),
		   CCAlgorithm(kCCAlgorithmDES),
		   options,
		   keyBytes, key.count,
		   ivBytes ?? [UInt8](repeating: 0, count: kCCBlockSizeDES),
		   data.bytes, data.count,
		   &buffer, buffer.count,
		   &bufferLength
	   )
	   
	   if cryptStatus == kCCSuccess {
		   let encryptedData = Data(bytes: buffer, count: bufferLength)
		   return encryptedData.base64EncodedString()
	   } else {
		   console.log("Error: \(cryptStatus)")
		   return ""
	   }
    }
    
    static func desDecrypt(input: String, key: String, mode: String = "ECB", iv: String? = nil) -> String {
       guard key.count == kCCKeySizeDES else {
		   console.log("Key length must be 8 bytes.")
		   return ""
	   }
	   
	   guard let data = Data(base64Encoded: input) else {
		   console.log("Invalid base64 input.")
		   return ""
	   }
	   console.log(mode.lowercased() ,iv,"---")
	   let keyData = key.data(using: .utf8)!
	   let keyBytes = [UInt8](keyData)
	   
	   var options: CCOptions = CCOptions(kCCOptionPKCS7Padding)
	   var ivBytes: [UInt8]?
	   
	   if mode.lowercased() == "ecb" {
		   options |= CCOptions(kCCOptionECBMode)
	   } else if mode.lowercased() == "cbc", let iv = iv {
		   ivBytes = [UInt8](iv.data(using: .utf8)!)
	   } else {
		   console.log("Invalid mode or missing IV for CBC.")
		   return ""
	   }
	   
	   var buffer = [UInt8](repeating: 0, count: data.count + kCCBlockSizeDES)
	   var bufferLength = 0
	   
	   let cryptStatus = CCCrypt(
		   CCOperation(kCCDecrypt),
		   CCAlgorithm(kCCAlgorithmDES),
		   options,
		   keyBytes, key.count,
		   ivBytes ?? [UInt8](repeating: 0, count: kCCBlockSizeDES),
		   data.bytes, data.count,
		   &buffer, buffer.count,
		   &bufferLength
	   )
	   
	   if cryptStatus == kCCSuccess {
		   let decryptedData = Data(bytes: buffer, count: bufferLength)
		   return String(data: decryptedData, encoding: .utf8) ?? ""
	   } else {
		   console.log("Error: \(cryptStatus)")
		   return ""
	   }
    }
	
	static func generateRSAKeyPair(keySize: Int) throws -> RSARandomKey {
		let privateKeyAttributes: [String: Any] = [
			kSecAttrIsPermanent as String: false,
			kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
		]

		let publicKeyAttributes: [String: Any] = [
			kSecAttrIsPermanent as String: false,
			kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
		]

		let keyPairAttributes: [String: Any] = [
			kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
			kSecAttrKeySizeInBits as String: keySize,
			kSecPrivateKeyAttrs as String: privateKeyAttributes,
			kSecPublicKeyAttrs as String: publicKeyAttributes
		]

		var publicKey: SecKey?
		var privateKey: SecKey?

		let status = SecKeyGeneratePair(keyPairAttributes as CFDictionary, &publicKey, &privateKey)

		guard status == errSecSuccess, let publicKey = publicKey, let privateKey = privateKey else {
			throw RSAError.keyGenerationFailed(status: status)
		}

		guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
			throw RSAError.publicKeyConversionFailed
		}

		guard let privateKeyData = SecKeyCopyExternalRepresentation(privateKey, nil) as Data? else {
			throw RSAError.privateKeyConversionFailed
		}

		let publicKeyBase64 = publicKeyData.base64EncodedString()
		let privateKeyBase64 = privateKeyData.base64EncodedString()

		return RSARandomKey(publicKey: publicKeyBase64, privateKey: privateKeyBase64)
	}
	    
	static func rsaDecrypt(_ content: String, privateKey: String) throws -> String {
	        guard let data = Data(base64Encoded: content) else {
	            throw RSAError.base64DecodingFailed
	        }
	        
	        // Prepare the key
	        guard let privateKeyData = privateKey
	            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
	            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
	            .replacingOccurrences(of: "\n", with: "")
	            .data(using: .utf8) else {
	            throw RSAError.keyCreationFailed
	        }
	        
	        let privateKeyBase64 = Data(base64Encoded: privateKeyData)!
	        
	        var attributes: [String: Any] = [
	            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
	            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
	            kSecAttrKeySizeInBits as String: 2048
	        ]
	        
	        var error: Unmanaged<CFError>?
	        guard let privateSecKey = SecKeyCreateWithData(privateKeyBase64 as CFData,
	                                                      attributes as CFDictionary,
	                                                      &error) else {
	            throw RSAError.keyCreationFailed
	        }
	        
	        // Decrypt
	        let algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1
	        
	        guard SecKeyIsAlgorithmSupported(privateSecKey, .decrypt, algorithm) else {
	            throw RSAError.decryptionFailed
	        }
	        
	        var decryptError: Unmanaged<CFError>?
	        guard let decryptedData = SecKeyCreateDecryptedData(privateSecKey,
	                                                           algorithm,
	                                                           data as CFData,
	                                                           &decryptError) as Data? else {
	            throw RSAError.decryptionFailed
	        }
	        
	        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
	            throw RSAError.dataConversionFailed
	        }
	        
	        return decryptedString
	    }
	    
	// Encrypt with public key
	static func rsaEncrypt(_ content: String, publicKey: String) throws -> String {
		guard let data = content.data(using: .utf8) else {
			throw RSAError.dataConversionFailed
		}
		
		// Prepare the key
		guard let publicKeyData = publicKey
			.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
			.replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
			.replacingOccurrences(of: "\n", with: "")
			.data(using: .utf8) else {
			throw RSAError.keyCreationFailed
		}
		
		let publicKeyBase64 = Data(base64Encoded: publicKeyData)!
		
		var attributes: [String: Any] = [
			kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
			kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
			kSecAttrKeySizeInBits as String: 2048
		]
		
		var error: Unmanaged<CFError>?
		guard let publicSecKey = SecKeyCreateWithData(publicKeyBase64 as CFData,
													attributes as CFDictionary,
													&error) else {
			throw RSAError.keyCreationFailed
		}
		
		// Encrypt
		let algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1
		
		guard SecKeyIsAlgorithmSupported(publicSecKey, .encrypt, algorithm) else {
			throw RSAError.encryptionFailed
		}
		
		var encryptError: Unmanaged<CFError>?
		guard let encryptedData = SecKeyCreateEncryptedData(publicSecKey,
														  algorithm,
														  data as CFData,
														  &encryptError) as Data? else {
			throw RSAError.encryptionFailed
		}
		
		return encryptedData.base64EncodedString()
	}
	    
    
    
	// // pkcs1 2048位
 //    static func rsaEncrypt(input: String, publicKey: String) -> String {
	// 	// https://github.com/1691665955/MZRSA_Swift
	// 	let codestr = MZRSA.encryptString(input,publicKey:publicKey)
	// 	return codestr ?? ""
		
 //    }
 //    // pkcs1 2048位
 //    static func rsaDecrypt(input: String, privateKey: String) -> String {
	// 	let codestr = MZRSA.decryptString(input,privateKey:privateKey)
	// 	return codestr ?? ""
 //    }
    
    
    static func rc4Encrypt(data : String,key:String) -> String {
		
       return rc4Encrypt2(data:data,key:key)
    }
    
    static func rc4Decrypt(encryptedHex: String, key: String) -> String {
		
		
       return rc4Decrypt2(encryptedHex:encryptedHex,key:key)
    }
}
