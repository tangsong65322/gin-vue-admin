# x-tips-s

### 特性说明
主要是用来一段在顶部或者底部的一段文字提示,而且不受干扰,自行消失,也不影响用户操作.

. 可以重复打开，或者连续打开不用担心前一个是否关闭，我内部会检测关闭上一个提示。

### 兼容性

| IOS | Andriod | WEB |
| --- | --- | --- |
| 12+| 4.2+ | 所有浏览器 |

### 开发文档

**浏览器端需要你把目录中的```remixicon.ttf```复制到static目录下**


调用：
```ts
import { showTips,hideTips,XTIPS_TYPE } from "@/uni_modules/x-tips-s"
//  打开提示
showTips({title:"提示消息"} as XTIPS_TYPE)
// 手动隐藏
hideTips()
```

参数配置：

下面的图标iconCode，同组件库x-icon是相同的字体图标，请打开图标网站：[查看](https://remixicon.com/)
找到直接想要的图标后 复制 unicode ，不是名称。比如：&#xED29;我们只要取ED29
下面的参数图标iconCode就是ED29 **iconCode:'ED29'**

**XTIPS_TYPE**

```ts
// 所有参数都是可选的， 但标题是必选。
export type XTIPS_TYPE = {
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
	 * 允许穿透
	 * @default false
	 */
	maskDisableClik?:boolean,
	position?:'top'|'bottom',
	/**
	 * 偏移量
	 * @default 50
	 */
	offset?:number
}

```