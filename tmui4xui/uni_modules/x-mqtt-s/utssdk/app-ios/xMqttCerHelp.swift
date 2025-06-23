import Foundation
import Security
// UTS内置对象的引用
import DCloudUTSFoundation
func getClientCertFromP12File(resourcePath: String, certPassword: String) -> [String: NSObject]? {
    do {
        // 读取证书文件数据
        let p12Data = try Data(contentsOf: URL(fileURLWithPath: resourcePath))
        
        // 创建密钥字典用于读取p12文件
        let key = kSecImportExportPassphrase as String
        let options : NSDictionary = [key: certPassword]
        
        var items : CFArray?
        let securityError = SecPKCS12Import(p12Data as NSData, options, &items)
        
        guard securityError == errSecSuccess else {
            if securityError == errSecAuthFailed {
                console.log("ERROR: SecPKCS12Import returned errSecAuthFailed. Incorrect password?")
            } else {
                console.log("Failed to open the certificate file", resourcePath)
            }
            return nil
        }
        
        guard let theArray = items, CFArrayGetCount(theArray) > 0 else {
            return nil
        }
        
        let dictionary = (theArray as NSArray).object(at: 0)
        guard let identity = (dictionary as AnyObject).value(forKey: kSecImportItemIdentity as String) as? NSObject else {
            return nil
        }
        
        return [
            "useCertificateChainValidation": NSNumber(value: true),
            "useSSLCertificateVerification": NSNumber(value: true),
            "clientCertificate": identity
        ]
    } catch {
        console.log("读取证书文件失败", resourcePath)
        return nil
    }
}

// 将PEM格式的证书转换为DER格式
func convertPEMToDER(pemString: String) -> Data? {
    // 移除所有空格和换行符
    var cleanedString = pemString.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // 检查是否包含PEM证书的头尾标记
    let beginCertPattern = "-----BEGIN CERTIFICATE-----"
    let endCertPattern = "-----END CERTIFICATE-----"
    
    // 如果没有找到标准的PEM头尾标记，记录日志并尝试直接解码
    if !cleanedString.contains(beginCertPattern) || !cleanedString.contains(endCertPattern) {
        console.log("警告: PEM证书格式不标准，缺少标准头尾标记")
        // 尝试直接解码，假设整个字符串都是Base64编码
        let noWhitespace = cleanedString.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        return Data(base64Encoded: noWhitespace)
    }
    
    // 提取BEGIN和END标记之间的内容
    guard let startRange = cleanedString.range(of: beginCertPattern),
          let endRange = cleanedString.range(of: endCertPattern) else {
        console.log("无法定位PEM证书的头尾标记位置")
        return nil
    }
    
    // 获取BEGIN标记之后的内容
    let afterBeginIndex = cleanedString.index(after: startRange.upperBound)
    // 获取END标记之前的内容
    let beforeEndIndex = endRange.lowerBound
    
    // 提取Base64编码部分
    let base64Content = String(cleanedString[afterBeginIndex..<beforeEndIndex])
    
    // 移除所有空格和换行
    let noWhitespace = base64Content.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
    
    // 解码Base64
    guard let data = Data(base64Encoded: noWhitespace) else {
        console.log("Base64解码失败，证书内容可能损坏")
        return nil
    }
    
    return data
}

func getClientCertFromCrtFile(resourcePath: String) -> [String: NSObject]? {
	
	do {
		 // 读取证书文件数据
		let pemData = try Data(contentsOf: URL(fileURLWithPath: resourcePath))
		// 将证书数据转换为字符串
		guard let pemString = String(data: pemData, encoding: .utf8) else {
			console.log("将证书数据转换为字符串失败")
			return nil
		}
		// 将PEM格式转换为DER格式
		guard let derData = convertPEMToDER(pemString: pemString) else {
			console.log("转换PEM到DER格式失败")
			return nil
		}
		// 创建SecCertificate对象
		guard let certificate = SecCertificateCreateWithData(nil, derData as CFData) else {
			console.log("创建SecCertificate对象失败")
			return nil
		}
		
		return [
		    "useCertificateChainValidation": NSNumber(value: true),
		    "useSSLCertificateVerification": NSNumber(value: true),
		    "kCFStreamSSLCertificates": [certificate] as NSArray
		]
	} catch {
		console.log("读取证书文件失败",resourcePath)
		return nil
	}
    
}

