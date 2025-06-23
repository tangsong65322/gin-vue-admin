# x-base64toarraybuff-s

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 开发文档

这是一个跨平台的base64和ArrayBuffer转换工具，提供了两个主要API：

#### base64ToArrayBuffer

将Base64字符串转换为ArrayBuffer。

**参数：**
- data: string - 需要转换的Base64字符串

**返回值：**
- ArrayBuffer - 转换后的二进制数据

**示例：**
```ts
import { base64ToArrayBuffer } from "@/uni_modules/x-base64toarraybuff-s"

const base64Str = "SGVsbG8gV29ybGQ="
const buffer = base64ToArrayBuffer(base64Str)
```

#### arrayBufferToBase64

将ArrayBuffer转换为Base64字符串。

**参数：**
- data: ArrayBuffer - 需要转换的二进制数据

**返回值：**
- string - 转换后的Base64字符串

**示例：**
```ts
import { arrayBufferToBase64 } from "@/uni_modules/x-base64toarraybuff-s"

const buffer = new ArrayBuffer(8)
const base64Str = arrayBufferToBase64(buffer)
```

### 使用说明

1. 使用前，如果是win请先在页面引用，打基座，再编译使用
2. 如果你是Mac用户不需要打基座，直接引用使用
3. 如果你是加密插件用户，不管是win,mac都要打基座。

### 注意事项

1. 该插件在所有平台（iOS、Android、Web、小程序）上均可用
2. 转换过程中会自动处理不同平台的实现差异，开发者无需关心具体实现
3. 建议在处理大量数据时进行适当的性能优化