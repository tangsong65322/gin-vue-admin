package uts.sdk.modules.utsXcryptoS

import java.security.*
import java.security.spec.X509EncodedKeySpec
import java.security.spec.PKCS8EncodedKeySpec
import javax.crypto.*
import javax.crypto.spec.SecretKeySpec
import javax.crypto.spec.IvParameterSpec
import android.util.Base64
import java.nio.charset.Charset
import io.dcloud.uts.console
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.spec.RSAKeyGenParameterSpec


import java.security.KeyFactory




// 定义支持的输出长度枚举
enum class OutputLength(val length: Int) {
	LENGTH_16(8),  // 8 bytes = 16 hex chars
	LENGTH_32(16), // 16 bytes = 32 hex chars
	LENGTH_64(32)  // 32 bytes = 64 hex chars
}
data class RSARandomKey(val publicKey: String, val privateKey: String)


class UniversalCryptoHelper {
	companion object {
		// MD5 Encryption ,32位加密
		fun md5(input: String): String {
		    val md = MessageDigest.getInstance("MD5")
		    val digest = md.digest(input.toByteArray())
		    return digest.joinToString("") { "%02x".format(it) }
		}
		
		// BASE64 Encoding and Decoding
		fun base64Encode(input: String): String = Base64.encodeToString(input.toByteArray(), android.util.Base64.NO_WRAP)
		fun base64Decode(input: String): String = String(Base64.decode(input, Base64.DEFAULT))
		
		// HMAC with SHA-256
		fun hmacSha256(key: String, data: String): String {
		    val secretKey = SecretKeySpec(key.toByteArray(), "HmacSHA256")
		    val mac = Mac.getInstance("HmacSHA256")
		    mac.init(secretKey)
		    val hash = mac.doFinal(data.toByteArray())
		    return hash.joinToString("") { "%02x".format(it) }
		}
		
		// SHA-1 and SHA-256 Hashing
		fun sha1(input: String): String {
		    val md = MessageDigest.getInstance("SHA-1")
		    val digest = md.digest(input.toByteArray())
		    return digest.joinToString("") { "%02x".format(it) }
		}
		
		fun sha256(input: String): String {
		    val md = MessageDigest.getInstance("SHA-256")
		    val digest = md.digest(input.toByteArray())
		    return digest.joinToString("") { "%02x".format(it) }
		}
		
		/**
		 * 计算SHA-512哈希值
		 * @param input 需要计算哈希的字符串
		 * @return 哈希值的十六进制字符串
		 */
		fun sha512(input: String): String {
		    val md = MessageDigest.getInstance("SHA-512")
		    val digest = md.digest(input.toByteArray())
		    return digest.joinToString("") { "%02x".format(it) }
		}
		
		/**
		 * 使用HMAC-SHA512算法计算消息认证码
		 * @param key 密钥
		 * @param data 需要认证的数据
		 * @return HMAC值的十六进制字符串
		 */
		fun hmacSha512(key: String, data: String): String {
		    val secretKey = SecretKeySpec(key.toByteArray(), "HmacSHA512")
		    val mac = Mac.getInstance("HmacSHA512")
		    mac.init(secretKey)
		    val hmacBytes = mac.doFinal(data.toByteArray())
		    return hmacBytes.joinToString("") { "%02x".format(it) }
		}
		
		fun generateAesKey(key: String, keySize: Int = 16): ByteArray {
		    val fixedKey = key.padEnd(keySize, '0') // 填充到 16 字节（128 位）
		    return fixedKey.toByteArray().copyOf(keySize) // 截断或扩展为 16 字节
		}
		
		fun generateDesKey(key: String,keySize: Int = 24): ByteArray {
		    // 确保密钥长度为24字节，不足时用0填充，过长时截断
		    val keyBytes = key.toByteArray()
		    val paddedKey = ByteArray(keySize)
		    if (keyBytes.size < keySize) {
		        System.arraycopy(keyBytes, 0, paddedKey, 0, keyBytes.size)
		    } else {
		        System.arraycopy(keyBytes, 0, paddedKey, 0, keySize)
		    }
		    return paddedKey
		}
		fun generateDesKey2(key: ByteArray,keySize: Int = 24): ByteArray {
		    // 确保密钥长度为24字节，不足时用0填充，过长时截断
		    val keyBytes = key
		    val paddedKey = ByteArray(keySize)
		    if (keyBytes.size < keySize) {
		        System.arraycopy(keyBytes, 0, paddedKey, 0, keyBytes.size)
		    } else {
		        System.arraycopy(keyBytes, 0, paddedKey, 0, keySize)
		    }
		    return paddedKey
		}
		/**
		 * 返回编码为base64,cbc或者ecb,填充这pkcs5/pkdcs7,密钥和iv偏移均为16位
		 */
		fun aesEncrypt(input: String, key: String,mode:String,iv: String? = null,keySize:Int?=16): String {
			
			if(mode=="ECB"){
				val secretKey = SecretKeySpec(generateDesKey(key,keySize?:16), "AES")
				val cipher = Cipher.getInstance("AES/ECB/PKCS5Padding")
				cipher.init(Cipher.ENCRYPT_MODE, secretKey)
				val encrypted = cipher.doFinal(input.toByteArray())
				return Base64.encodeToString(encrypted, Base64.NO_WRAP)
			}
			// cbc
			val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
			val keySpec = SecretKeySpec(generateDesKey(key,keySize?:16), "AES")
			
			val ivSpecBz = generateDesKey(iv?:"",16)
			val ivSpec = IvParameterSpec(ivSpecBz)
			cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec)
			val encrypted = cipher.doFinal(input.toByteArray())
			return Base64.encodeToString(encrypted, Base64.NO_WRAP)
		}
		fun aesEncrypt2(input: ByteArray, key: ByteArray,mode:String,iv: ByteArray? = null,keySize:Int?=16): ByteArray {
			
			if(mode=="ECB"){
				val secretKey = SecretKeySpec(generateDesKey2(key,keySize?:16), "AES")
				val cipher = Cipher.getInstance("AES/ECB/PKCS5Padding")
				cipher.init(Cipher.ENCRYPT_MODE, secretKey)
				val encrypted = cipher.doFinal(input)
				return encrypted
			}
			// cbc
			val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
			val keySpec = SecretKeySpec(generateDesKey2(key,keySize?:16), "AES")
			
			val ivSpecBz = generateDesKey2(iv?:ByteArray(keySize?:16),16)
			val ivSpec = IvParameterSpec(ivSpecBz)
			cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec)
			val encrypted = cipher.doFinal(input)
		
			return encrypted
		}
		/**
		 * 加密文本为base64,cbc或者ecb,填充这pkcs5/pkdcs7,密钥和iv偏移均为16位,返回字符串.
		 */
		fun aesDecrypt(input: String, key: String,mode:String,iv: String? = null,keySize:Int?=16): String {
			if(mode=="ECB"){
				val secretKey = SecretKeySpec(generateDesKey(key,keySize?:16), "AES")
				val cipher = Cipher.getInstance("AES/ECB/PKCS5Padding")
				cipher.init(Cipher.DECRYPT_MODE, secretKey)
				val decrypted = cipher.doFinal(Base64.decode(input, Base64.DEFAULT)) 
				return String(decrypted) 
			}
		   // cbc
		   val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
		   val keySpec = SecretKeySpec(generateDesKey(key,keySize?:16), "AES")
		   // val ivSpec = adjustIV(iv?:"":iv,keySize?:16)
		   // val ivSpec = IvParameterSpec(iv!!.toByteArray())
		   val ivSpecBz = generateDesKey(iv?:"",16)
		   val ivSpec = IvParameterSpec(ivSpecBz)
		   cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec)
		   val decodedBytes = Base64.decode(input, Base64.DEFAULT)
		   val decrypted = cipher.doFinal(decodedBytes)
		   return String(decrypted)
			
		}
		
		
		fun aesDecrypt2(input: ByteArray, key: ByteArray,mode:String,iv: ByteArray? = null,keySize:Int?=16): ByteArray {
			if(mode=="ECB"){
				val secretKey = SecretKeySpec(generateDesKey2(key,keySize?:16), "AES")
				val cipher = Cipher.getInstance("AES/ECB/PKCS5Padding")
				cipher.init(Cipher.DECRYPT_MODE, secretKey)
				val decrypted = cipher.doFinal(input)
				// val decrypted = cipher.doFinal(Base64.decode(input, Base64.DEFAULT)) 
				return decrypted
			}
		   // cbc
		   val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
		   val keySpec = SecretKeySpec(generateDesKey2(key,keySize?:16), "AES")
		   // val ivSpec = adjustIV(iv?:"":iv,keySize?:16)
		   // val ivSpec = IvParameterSpec(iv!!.toByteArray())
		   val ivSpecBz = generateDesKey2(iv?:ByteArray(keySize?:16),16)
		   val ivSpec = IvParameterSpec(ivSpecBz)
		   cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec)
		   // val decodedBytes = Base64.decode(input, Base64.DEFAULT)
		   val decrypted = cipher.doFinal(input)
		   return decrypted
			
		}
	
		
		
		// DES Encryption and Decryption
		fun desEncrypt(input: String, key: String,mode:String,iv: String? = null): String {
		    val secretKey = SecretKeySpec(generateDesKey(key), "DESede")
			val cipher: Cipher = when (mode) {
				"ECB" -> Cipher.getInstance("DESede/ECB/PKCS5Padding")
				"CBC" -> Cipher.getInstance("DESede/CBC/PKCS5Padding")
				else -> throw IllegalArgumentException("Unsupported mode: $mode")
			}
		
			if (mode == "CBC" && iv == null) {
				throw IllegalArgumentException("IV must not be null for CBC mode")
			}
		
			if (mode == "CBC") {
				val ivSpec = IvParameterSpec(iv!!.toByteArray())
				cipher.init(Cipher.ENCRYPT_MODE, secretKey, ivSpec)
			} else {
				cipher.init(Cipher.ENCRYPT_MODE, secretKey)
			}
		
			val encrypted = cipher.doFinal(input.toByteArray())
			return Base64.encodeToString(encrypted, android.util.Base64.NO_WRAP)
		}
		
		fun desDecrypt(input: String, key: String,mode:String,iv: String? = null): String {
		    val secretKey = SecretKeySpec(generateDesKey(key), "DESede")
			val cipher: Cipher = when (mode) {
				"ECB" -> Cipher.getInstance("DESede/ECB/PKCS5Padding")
				"CBC" -> Cipher.getInstance("DESede/CBC/PKCS5Padding")
				else -> throw IllegalArgumentException("Unsupported mode: $mode")
			}
		
			if (mode == "CBC" && iv == null) {
				throw IllegalArgumentException("IV must not be null for CBC mode")
			}
		
			if (mode == "CBC") {
				val ivSpec = IvParameterSpec(iv!!.toByteArray())
				cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec)
			} else {
				cipher.init(Cipher.DECRYPT_MODE, secretKey)
			}
		
			val decrypted = cipher.doFinal(Base64.decode(input, Base64.DEFAULT))
			return String(decrypted)
		}
		
		
		
		// Convert String to PublicKey
		fun stringToPublicKey(publicKeyStr: String): PublicKey {
		
		   val keyBytes = Base64
		   .decode(publicKeyStr.replace("-----BEGIN PUBLIC KEY-----", "")
		   .replace("-----END PUBLIC KEY-----", "")
		   .replace("\r", "")
		   .replace("\n", "")
		   .replace("\t", "")
		   .replace(" ", "")
		   , Base64.DEFAULT
		   )
		  
		   val keySpec = X509EncodedKeySpec(keyBytes)
		   val keyFactory = KeyFactory.getInstance("RSA")
		   return keyFactory.generatePublic(keySpec)
		}
		
		// Convert String to PrivateKey
		fun stringToPrivateKey(privateKeyStr: String): PrivateKey {
		    val keyBytes = Base64.decode(privateKeyStr.replace("-----BEGIN PRIVATE KEY-----", "")
			.replace("-----END PRIVATE KEY-----", "")
			.replace("\r", "")
			.replace("\n", "")
			.replace("\t", "")
			.replace(" ", "")
			, Base64.DEFAULT
			)
			val keySpec = PKCS8EncodedKeySpec(keyBytes)
			val keyFactory = KeyFactory.getInstance("RSA")
			return keyFactory.generatePrivate(keySpec)
		}
		
		
		fun generateRSAKeyPair(keySize: Int = 2048): RSARandomKey {
		    val keyPairGenerator = KeyPairGenerator.getInstance("RSA")
		    keyPairGenerator.initialize(RSAKeyGenParameterSpec(keySize, RSAKeyGenParameterSpec.F4))
		    val keyPair: KeyPair = keyPairGenerator.generateKeyPair()
		
		    // 将公钥转换为X.509格式
		    val x509EncodedPublicKey = keyPair.public.encoded
		    val publicKeyString = Base64.encodeToString(x509EncodedPublicKey, Base64.NO_WRAP)
		
		    // 将私钥转换为PKCS#8格式
		    val pkcs8EncodedPrivateKey = keyPair.private.encoded
		    val privateKeyString = Base64.encodeToString(pkcs8EncodedPrivateKey, Base64.NO_WRAP)
		
		    return RSARandomKey(publicKeyString, privateKeyString)
		}
		
		
		// 默认是PKCS1，填充：（OAEP）RSA/ECB/OAEPWithSHA-1AndMGF1Padding或者（PKCS1）RSA/ECB/PKCS1Padding
		fun rsaEncrypt(input: String, publicKeyStr: String): String {
		     val publicKey = stringToPublicKey(publicKeyStr)
			val cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding")
			cipher.init(Cipher.ENCRYPT_MODE, publicKey)
			val encrypted = cipher.doFinal(input.toByteArray())
			return Base64.encodeToString(encrypted, Base64.NO_WRAP)
			
		}
		// input是base64,PKCS1填充生成的加密内容
		fun rsaDecrypt(input: String, privateKeyStr: String): String {
		    val privateKey = stringToPrivateKey(privateKeyStr)
			val cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding")
			cipher.init(Cipher.DECRYPT_MODE, privateKey)
			val decrypted = cipher.doFinal(Base64.decode(input, Base64.DEFAULT))
			return String(decrypted)
		}
		
		
		
		
		fun rc4Init(key: ByteArray): ByteArray {
		    val s = ByteArray(256) { it.toByte() }
		    var j = 0
		    
		    for (i in 0..255) {
		        j = (j + s[i].toInt() + key[i % key.size].toInt() and 0xFF) and 0xFF
		        val temp = s[i]
		        s[i] = s[j]
		        s[j] = temp
		    }
		    
		    return s
		}
		
		fun rc4Process(data: ByteArray, key: ByteArray, outputLength: OutputLength): ByteArray {
		    val s = rc4Init(key)
		    val result = ByteArray(outputLength.length) // 使用指定的字节长度
		    var i = 0
		    var j = 0
		    
		    for (n in result.indices) {
		        i = (i + 1) and 0xFF
		        j = (j + s[i].toInt() and 0xFF) and 0xFF
		        
		        val temp = s[i]
		        s[i] = s[j]
		        s[j] = temp
		        
		        val t = (s[i].toInt() + s[j].toInt() and 0xFF) and 0xFF
		        val k = s[t].toInt() and 0xFF
		        
		        result[n] = if (n < data.size) {
		            (data[n].toInt() xor k).toByte()
		        } else {
		            k.toByte()
		        }
		    }
		    
		    return result
		}
		//输出是hex字符串，密钥是8位字符
		fun rc4Encrypt(data: String, key: String): String {
		    val dataBytes = data.toByteArray()
		    val keyBytes = key.toByteArray()
		    val encrypted = rc4Process(dataBytes, keyBytes, OutputLength.LENGTH_16)
		    return encrypted.joinToString("") { "%02x".format(it) }
		}
		//输入encryptedHex是hex字符串,返回是string，密钥是8位字符
		fun rc4Decrypt(encryptedHex: String, key: String): String {
		    val encryptedBytes = encryptedHex.chunked(2)
		        .map { it.toInt(16).toByte() }
		        .toByteArray()
		    val keyBytes = key.toByteArray()
		    val decrypted = rc4Process(encryptedBytes, keyBytes, OutputLength.LENGTH_16)
		    return decrypted.toString(Charset.defaultCharset()).trim('\u0000')
		}
		
		
		
		
	}
}
