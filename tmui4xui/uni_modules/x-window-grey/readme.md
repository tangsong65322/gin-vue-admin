# x-window-grey
### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

主要用于特殊时间时的整体app变灰,比如国家哀悼日,让页面变灰色.

理论上uniapp也支持,uniappx也支持.

### 说明
这是tmui4.0|XUI的原生插件附赠插件

### 兼容性

| IOS | Andriod | WEB |
| --- | --- | --- |
| 13+ | 支持 | 支持 |



### 使用

如果是安卓请务必打自定义基座，如果ios：你在mac环境下配置好了环境无需打包本地编译，如果win开发ios需要打包基座。

**需要注意的是**
变灰只针对当前窗口所有内容,如果你想任何页面,自动变灰,你可能需要自行封装,然后在onShow中执行变灰操作.

```ts

import { setWindowGrey,removeWindowGrey } from "@/uni_modules/x-window-grey";
// 让页面变灰
setWindowGrey()
// 恢复页面
removeWindowGrey()

```
