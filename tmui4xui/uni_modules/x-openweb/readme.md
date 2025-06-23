# x-openweb
### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

应用app打开外链或者h5打开链接使用.
微信使用的是webview，因为你的小程序需要企业帐号权限，个人小程序无法使用。

### 说明
这是tmui4.0|XUI的原生插件附赠插件

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 使用

如果是安卓请务必打自定义基座，如果ios：你在mac环境下配置好了环境无需打包本地编译，如果win开发ios需要打包基座。

```ts

import {openWeb} from "@/uni_modules/x-openweb"
openWeb(url)

```