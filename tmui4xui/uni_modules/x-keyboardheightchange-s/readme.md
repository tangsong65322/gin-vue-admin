# x-keyboardheightchange-s

### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

### 介绍

`x-keyboardheightchange-s` 是一个用于监听键盘高度变化的UTS插件，可以实时获取键盘弹出和收起时的高度变化，方便开发者处理键盘遮挡UI的问题。该插件会自动处理安全区域高度，返回实际可用的键盘高度值。

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | x | x |

### API 说明

#### keyboardHeightChange(callback)

监听键盘高度变化，返回一个取消监听的函数。

**参数说明：**

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| callback | Function | 是 | 键盘高度变化的回调函数，参数为键盘高度(单位px) |

**返回值：**

| 类型 | 说明 |
| --- | --- |
| Function | 取消监听的函数，调用此函数可以注销键盘高度监听 |

### 使用示例

```typescript
// 引入模块
import { keyboardHeightChange } from '@/uni_modules/x-keyboardheightchange-s/utssdk';

// 注册键盘高度监听
const cancelKeyboardListener = keyboardHeightChange((height: number) => {
  console.log('当前键盘高度：', height);
  
  // 键盘弹出
  if (height > 0) {
    // 处理键盘弹出逻辑
  } 
  // 键盘收起
  else {
    // 处理键盘收起逻辑
  }
});

// 在组件销毁时注销监听
onUnload(() => {
  // 调用返回的函数取消监听
  cancelKeyboardListener();
});
```

### 注意事项

1. 该插件已自动处理安全区域高度，返回的高度值已减去底部安全区域高度
2. iOS平台使用系统通知监听键盘高度变化
3. Android平台通过原生方法监听键盘高度变化
4. 只有当键盘高度发生变化时才会触发回调
5. 键盘收起时，回调函数的参数为0
6. 请务必在组件销毁时调用返回的取消函数，避免内存泄漏


