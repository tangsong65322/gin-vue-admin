# x-loading-s

### 特性说明

主要是用来代替uni.showLoading的，相比优化有：

1. 高自动适应，因此可以添加超长的title文字。
2. 图标可以任意更新，大小，颜色等
3. 可以添加title标题，允许改变字号,颜色
4. 支持渐隐动画效果，包括遮罩层渐入和内容缩放
5. 遮罩层会阻止点击穿透，保护底层内容

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 开发文档

**浏览器端需要你把目录中的```remixicon.ttf```复制到static目录下**

调用：
```ts
import { showLoading, hideXloading, XLOADINGS_TYPE } from "@/uni_modules/x-loading-s"
// 显示，字段参数全是可选的
showLoading({} as XLOADINGS_TYPE)
// 或者,null使用默认值
showLoading(null)
// 隐藏
hideXloading()

```

参数配置：

下面的图标iconCode，同组件库x-icon是相同的字体图标，请打开图标网站：[查看](https://remixicon.com/)
找到直接想要的图标后 复制 unicode ，不是名称。比如：&#xED29;我们只要取ED29
下面的参数图标iconCode就是ED29 **iconCode:'ED29'**

**XLOADINGS_TYPE**
```ts
// 所有参数都是可选的
export type XLOADINGS_TYPE = {
	// 图标颜色，默认：#2979ff
	iconColor?:string,
	// 内容背景色，默认：#fff
	contentBgColor?:string,
	// 遮罩层背景色，默认：rgba(0,0,0,0.3)
	maskBgColor?:string,
	// 图标大小，默认：42
	iconSize?:number,
	// 图标编码，默认：ED29
	iconCode?:string,
	// 提示文字
	title?:string,
	// 文字大小，默认：28
	titleSize?:number,
	// 文字颜色，默认：#333
	titleColor?:string,
	// 约定的宽，最小高值100，宽100，默认：220
	size?:number,
}
```

### 显示和隐藏时机

- 组件会在页面ready后显示
- 页面卸载时会自动隐藏
- 可以通过hideXloading()手动隐藏

### 动画效果

- 显示时有300ms的渐入动画
- 遮罩层透明度从0到1渐变
- 内容区域有缩放和透明度渐变效果
- 加载图标有持续旋转动画