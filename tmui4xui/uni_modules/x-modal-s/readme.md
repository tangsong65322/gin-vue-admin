# x-modal-s

### 特性说明

主要是用来代替uni.showModal的，相比优化有：
1. 高自动适应，因此可以添加超长的title文字。
2. 图标可以任意更新，大小，颜色等
3. 可以添加title标题，允许改变字号,颜色 及背景
4. 精致美观，可以定制界面达到与品牌相符的设计
5. 可以重复打开，或者连续打开不用担心前一个是否关闭，我内部会检测关闭上一个对话框。

**微信内使用官方的弹层，大多属性无效，只有同官方的属性会生效**

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 开发文档

**浏览器端需要你把目录中的```remixicon.ttf```复制到static目录下**

调用：
```ts
import { showModal,X_MODAL_TYPE} from "@/uni_modules/x-modal-s"
// 显示
showModal({
  title: "提醒框",
  content: "这是一条测试消息对话框，默认是按钮分离哦。",
  confirmText: "确定",
  cancelText: "取消",
  // 按钮分离模式
  isSplitBtn: true,
  // 点击遮罩是否关闭
  clickMaskClose: true,
  // 确认按钮回调
  confirm: () => {
    console.log("点击确认")
  },
  // 取消按钮回调
  cancel: () => {
    console.log("点击取消")
  },
  // 关闭回调
  close: () => {
    console.log("对话框关闭")
  }
} as X_MODAL_TYPE)
```

### 参数配置

下面的图标iconCode，同组件库x-icon是相同的字体图标，请打开图标网站：[查看](https://remixicon.com/)
找到直接想要的图标后 复制 unicode ，不是名称。比如：&#xED29;我们只要取ED29
下面的参数图标iconCode就是ED29 **iconCode:'ED29'**

**X_MODAL_TYPE参数说明**
```ts
export type X_MODAL_TYPE = {
  // 标题文字
  title?: string,
  // 内容文字
  content?: string,
  // 内容对齐方式：'center'(上下左右居中) 或 'left'(顶左对齐)
  contentAlign?: string,
  // 取消按钮文字
  cancelText?: string,
  // 取消按钮背景色
  cancelBgColor?: string,
  // 取消按钮文字颜色
  cancelColor?: string,
  // 确认按钮文字
  confirmText?: string,
  // 确认按钮背景色
  confirmBgColor?: string,
  // 确认按钮文字颜色
  confirmColor?: string,
  // 圆角大小
  radius?: number,
  // 确认按钮图标(Remix图标unicode)
  confirmIcon?: string,
  // 取消按钮图标(Remix图标unicode)
  cancelIcon?: string,
  // 标题文字颜色
  titleColor?: string,
  // 内容文字颜色
  contentColor?: string,
  // 按钮是否分离显示
  isSplitBtn?: boolean,
  // 对话框内容背景色
  contentBgColor?: string,
  // 遮罩背景色
  maskBgColor?: string,
  // 确认按钮回调
  confirm?: () => void,
  // 取消按钮回调
  cancel?: () => void,
  // 关闭回调
  close?: () => void,
  // 背景模糊效果(仅web端生效)
  isBlurMask?: boolean,
  // 对话框高度
  height?: number,
  // 对话框宽度
  width?: number,
  // 是否允许点击遮罩关闭
  clickMaskClose?: boolean,
  // 是否显示取消按钮
  showCancel?: boolean
}
```

### 平台差异说明

1. Web端
- 支持背景模糊效果(isBlurMask)
- 需将remixicon.ttf字体文件复制到static目录

2. 微信小程序
- 使用官方原生showModal组件
- 仅支持基础属性(title,content,confirmText,cancelText等)
- 不支持自定义样式

3. Android/iOS
- 完整支持所有特性
- 支持自定义按钮图标
- 支持按钮分离模式
- 支持遮罩点击关闭

### 使用示例

1. 基础用法
```ts
showModal({
  title: "提示",
  content: "这是一个基础对话框"
} as X_MODAL_TYPE)
```

2. 自定义按钮
```ts
showModal({
  title: "自定义按钮",
  content: "自定义按钮文字和颜色",
  confirmText: "知道了",
  confirmColor: "#2979ff",
  showCancel: false
} as X_MODAL_TYPE)
```

3. 带图标按钮
```ts
showModal({
  title: "带图标",
  content: "使用Remix图标库",
  confirmIcon: "ED29",
  cancelIcon: "EAD8"
} as X_MODAL_TYPE)
```

4. 居中内容
```ts
showModal({
  title: "居中内容",
  content: "内容上下左右居中对齐",
  contentAlign: "center"
} as X_MODAL_TYPE)
```