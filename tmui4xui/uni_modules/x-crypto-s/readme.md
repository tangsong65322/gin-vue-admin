# x-crypto-s
### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

加密插件

### 说明
这是tmui4.0|XUI的原生插件附赠插件，提供了多种加密算法的实现，包括MD5、Base64、SHA系列、AES、DES、RSA和RC4等。所有加密算法均采用原生加密代码实现，与CryptoJS加密结果完全一致。

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### API说明

#### MD5加密
```ts
function md5(str: string): string
```
- 参数：
  - str: 待加密的字符串
- 返回值：MD5加密后的字符串

#### Base64编解码
```ts
function base64Encode(str: string): string
function base64Decode(str: string): string
```
- 参数：
  - str: 待编码/解码的字符串
- 返回值：Base64编码/解码后的字符串
- 注意：在Web端加密中文字符时，需要先使用encodeURI处理

#### SHA系列加密
```ts
function sha256(str: string): string
function sha512(str: string): string
function sha1(str: string): string
function hmacSha256(key: string, data: string): string
function hmacSha512(key: string, data: string): string
```
- 参数：
  - str/data: 待加密的字符串
  - key: HMAC加密的密钥
- 返回值：对应算法加密后的字符串

#### AES加密
```ts
function aesEncrypt(key: string, data: string, mode: string = "ECB", iv: string|null = null, keySize: number|null = null): string
function aesDecrypt(key: string, data: string, mode: string = "ECB", iv: string|null = null, keySize: number|null = null): string
```
- 参数：
  - key: 加密密钥（UTF-8字符串，根据keySize截取和补足）
  - data: 待加密/解密的数据
  - mode: 加密模式，支持ECB和CBC
  - iv: 初始化向量
  - keySize: 密钥长度（16=128位, 24=192位, 32=256位）
- 返回值：加密/解密后的字符串

#### DES加密
```ts
function desEncrypt(key: string, data: string, mode: string = "ECB", iv: string|null = null): string
function desDecrypt(key: string, data: string, mode: string = "ECB", iv: string|null = null): string
```
- 参数：
  - key: 加密密钥
  - data: 待加密/解密的数据
  - mode: 加密模式，支持ECB和CBC
  - iv: 初始化向量
- 返回值：加密/解密后的字符串

#### RSA加密
```ts
function generateRSAKeyPair(keySize: number = 2048): RSARANDOMKEY
function rsaEncrypt(publicKey: string, data: string): string
function rsaDecrypt(privateKey: string, data: string): string
```
- 参数：
  - keySize: RSA密钥长度
  - publicKey: 公钥
  - privateKey: 私钥
  - data: 待加密/解密的数据
- 返回值：
  - generateRSAKeyPair: 返回包含publicKey和privateKey的对象
  - rsaEncrypt/rsaDecrypt: 加密/解密后的字符串

#### RC4加密
```ts
function rc4Encrypt(key: string, data: string): string
function rc4Decrypt(key: string, data: string): string
```
- 参数：
  - key: 加密密钥
  - data: 待加密/解密的数据
- 返回值：加密/解密后的字符串（hex格式）

### 使用示例

```ts
import {
  md5, sha256, sha512, sha1, hmacSha256, hmacSha512,
  base64Encode, base64Decode,
  aesEncrypt, aesDecrypt,
  desEncrypt, desDecrypt,
  rsaEncrypt, rsaDecrypt,
  rc4Encrypt, rc4Decrypt,
  generateRSAKeyPair
} from '@/uni_modules/x-crypto-s'

// MD5加密
const md5Result = md5("TMUI4.0X")

// Base64编解码
const base64Result = base64Encode("TMUI4.0X")
const decodedText = base64Decode(base64Result)

// SHA系列加密
const sha256Result = sha256("TMUI4.0X")
const hmacResult = hmacSha256("密钥", "TMUI4.0X")

// AES加密（CBC模式）
const aesResult = aesEncrypt(
  "1234567890abcdef",
  "TMUI4.0X",
  "CBC",
  "1234567890abcdef"
)
const aesDecrypted = aesDecrypt(
  "1234567890abcdef",
  aesResult,
  "CBC",
  "1234567890abcdef"
)

// RSA加密
const rsaKeys = generateRSAKeyPair()
const encrypted = rsaEncrypt(rsaKeys.publicKey, "TMUI4.0X")
const decrypted = rsaDecrypt(rsaKeys.privateKey, encrypted)
```

更多使用示例和在线加密对比工具：
- MD5/SHA对比：https://www.mklab.cn/utils/md5
- DES对比：https://www.mklab.cn/utils/des