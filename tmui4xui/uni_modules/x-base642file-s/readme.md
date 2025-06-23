# x-base642file-s

### 功能介绍

将Base64格式的图片数据转换为本地PNG文件，支持跨平台使用。

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### API文档

#### toPngFile(data: string): Promise<string>

将Base64格式的图片数据转换为本地PNG文件。

**参数说明：**
- data: Base64格式的图片数据字符串，支持带前缀（如：data:image/png;base64,）或纯Base64字符串

**返回值：**
- Promise<string>: 返回生成的PNG文件路径
  - 成功：resolve(文件路径)
  - 失败：reject(空字符串)

### 平台差异说明

- Android：文件保存在应用的外部缓存目录
- iOS：文件保存在应用的缓存目录
- Web：返回Blob URL
- 小程序：文件保存在小程序用户目录

### 使用示例

```ts
import { toPngFile } from "@/uni_modules/x-base642file-s"

// 示例：将Base64图片转换为本地文件
const convertToFile = async (base64Data: string) => {
    try {
        const filePath = await toPngFile(base64Data)
        console.log('文件保存成功：', filePath)
    } catch (error) {
        console.error('转换失败')
    }
}
```

### 注意事项

1. 使用前，Windows用户需要先在页面引用，打基座，再编译使用
2. Mac用户可直接引用使用
3. 建议在处理大量数据时进行适当的性能优化
4. 生成的文件会保存在各平台对应的缓存目录中，请注意及时清理不需要的文件