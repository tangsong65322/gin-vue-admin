# x-call-phone
### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

拨打号码插件，支持跨平台调用系统拨号功能。

### 说明
这是tmui4.0|XUI的原生插件附赠插件，提供了统一的API接口来实现拨打电话功能。

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 使用前准备

#### Android平台
需要在应用中申请电话权限（CALL_PHONE）。插件会自动处理权限申请流程，如果用户拒绝授权，将无法使用拨号功能。

#### iOS平台
无需特殊权限设置。

### 开发环境配置
- 如果是uniapp应用需要自定基座
- uniappx不需要定义基座，但win开发ios时需要
- 如果是mac开发uniappx不需要基座

### API接口

#### makePhone(tel: string)
拨打电话号码

**参数说明：**
- tel: string 类型，要拨打的电话号码

**平台差异说明：**
- Android 10及以上版本：使用ACTION_DIAL实现，直接跳转到拨号界面
- Android 10以下版本：使用ACTION_CALL实现，直接拨打电话
- iOS：统一使用系统拨号功能

**示例代码：**
```ts
import {makePhone} from "@/uni_modules/x-call-phone"

// 拨打电话
makePhone('10086')
```

### 注意事项
1. Android平台需要在应用启动时确保已获取CALL_PHONE权限
2. 不同Android版本的实现方式有所不同，以确保符合系统安全策略
3. 建议在调用接口前先进行平台判断，确保更好的兼容性