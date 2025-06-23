# x-clipboard-s

### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

### 介绍
这是tmui4.0|XUI的原生插件附赠插件，提供了跨平台的剪贴板操作功能。支持在Android、iOS、Web和小程序平台上进行文本内容的复制和获取操作。

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 注意事项
- Web平台：新版浏览器会自动请求剪贴板权限
- Android平台：使用系统ClipboardManager服务实现
- iOS平台：使用UIPasteboard实现
- 小程序：使用平台原生API实现

### API接口

#### setClipboardData(data: string): Promise<boolean>
设置剪贴板内容

**参数说明：**
- data：要设置的文本内容

**返回值：**
- Promise<boolean>：操作成功返回true，失败返回false

#### getClipboardData(): Promise<string>
获取剪贴板内容

**返回值：**
- Promise<string>：成功返回剪贴板文本内容，失败返回错误信息

### 使用示例

```ts
import { setClipboardData, getClipboardData } from "@/uni_modules/x-clipboard-s"

// 设置剪贴板内容
const setText = () => {
    setClipboardData("要复制的文本").then(ok => {
        if (ok) {
            uni.showToast({ title: "复制成功", icon: "success" })
        }
    }).catch(err => {
        uni.showToast({ title: "复制失败", icon: "error" })
    })
}

// 获取剪贴板内容
const getText = () => {
    getClipboardData().then((text: string) => {
        uni.showToast({
            title: text,
            icon: "none"
        })
    }).catch(err => {
        uni.showToast({
            title: "获取剪贴板内容失败",
            icon: "error"
        })
    })
}
```

### 常见问题
1. Web端获取剪贴板内容失败？
   - 检查浏览器是否授予了剪贴板访问权限
   - 确保在HTTPS环境下运行

2. Android/iOS端操作失败？
   - 检查应用是否具有剪贴板权限
   - 确保传入的是文本内容
