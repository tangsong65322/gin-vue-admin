# x-network-change

### 特性说明

用来监测网络状态变化，支持Android和iOS平台。插件会实时监听设备的网络连接状态，当网络状态发生变化时（如连接、断开等）会触发回调函数。

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持| 支持 |

### API说明

#### xNetChange(callback)
监听网络状态变化

**参数说明：**
- callback: `(connecting: boolean) => void`
  - connecting: 布尔值，true表示网络已连接，false表示网络已断开

#### xUnNetChange()
取消网络状态监听

#### isNetworkAvailable()
当前是否有网络，返回 `Promise<boolean>`

#### getNetworkType()
当前网络状态类型返回,部分浏览器支持返回具体类型 `Promise<xNetworkType | null> `
`export type xNetworkType = "WiFi"|"Mobile"|"WiredNetwork"|"Other"|null`

**注意事项：**
- 不使用时，记得要取消监视，避免内存泄漏
- 建议在页面卸载时（onUnload）调用xUnNetChange取消监听

### 使用示例

```ts
import { xNetChange, xUnNetChange,isNetworkAvailable,getNetworkType } from "@/uni_modules/x-network-change"

// 开始监听网络状态
xNetChange((netcon: boolean) => {
    if (netcon) {
        console.log("网络已连接")
        // 执行网络连接后的业务逻辑
    } else {
        console.log("网络已断开")
        // 执行网络断开后的业务逻辑
    }
})

// 在页面卸载时取消监听
onUnload(() => {
    xUnNetChange()
})

isNetworkAvailable().then((isNetConecting:boolean)=>{
	console.log("当前网络状态：",isNetConecting)
})
getNetworkType().then((netType)=>{
	console.log("当前网络类型：",netType)
})


```
