# x-toast-s

### 特性说明

主要是用来代替uni.showToast的，相比优化有：

1. 高自动适应，因此可以添加超长的title文字。
2. 图标可以任意更新，大小，颜色等
3. 可以添加title标题，允许改变字号,颜色 及背景
4. 精致美观，可以定制界面达到与品牌相符的设计
5. 可以重复打开，或者连续打开不用担心前一个是否关闭，我内部会检测关闭上一个提示。

**微信内使用官方的弹层，大多属性无效，只有同官方的属性会生效**

### 兼容性

| IOS | Andriod | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 开发文档

**浏览器端需要你把目录中的```remixicon.ttf```复制到static目录下**

调用：
```ts
import { showToast,XTOAST_TYPE } from "@/uni_modules/x-toast-s"
//  打开提示
showToast({title:"提示消息"} as XTOAST_TYPE)
// 手动隐藏
hideToast()
```

参数配置：

下面的图标iconCode，同组件库x-icon是相同的字体图标，请打开图标网站：[查看](https://remixicon.com/)
找到直接想要的图标后 复制 unicode ，不是名称。比如：&#xED29;我们只要取ED29
下面的参数图标iconCode就是ED29 **iconCode:'ED29'**

**XLOADINGS_TYPE**
```ts
// 所有参数都是可选的， 但标题是必选。
export type XTOAST_TYPE = {
	iconColor?:string,
	contentBgColor?:string,
	maskBgColor?:string,
	iconSize?:number,
	/**
	 * 正常应该填写图标的16进制符号如：EEC4
	 * 本组件允许几个状态名称使用默认图标，为空是info图标。
	 * warn,error,success,info
	 */
	iconCode?:string,
	/**
	 * 标题为空不显示。
	 */
	title:string,
	titleSize?:number,
	titleColor?:string,
	/**
	 * 几秒后消失，0 表示永不消失
	 */
	duration?:number,
	close?:()=>void,
	/** 宽 */
	size?:number,
	/**
	 * 禁用遮罩穿透点击事件
	 * @default true
	 */
	maskDisableClik?:boolean
}

```