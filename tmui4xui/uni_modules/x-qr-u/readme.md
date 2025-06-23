# x-qr-u
### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

### 功能特色

原生生成效率极高，请前往demo编辑内容，感受生成的速度，无延迟。

**如果你需要像商品一样的条码美观（仿国家商品码制式）请使用tmui4.0组件库中的x-barcode组件**

tmui4.0内置提供了常用的button,text,view等api原生界面的绘制，主要应用于：原生界面的绘制，由于是纯原生，
因此使用门槛较高，需要会UTS,安卓，IOS开发基础。


### 说明
这是tmui4.0|XUI的原生插件附赠插件。种子用户可免于购买。

非种子用户：

普通授权：10元
源码授权：38元

### 兼容性

| IOS | Andriod | WEB |
| --- | --- | --- |
| 支持9.0+ | 支持5.0+ | 不支持 |

### 使用

如果是安卓请务必打自定义基座，如果ios：你在mac环境下配置好了环境无需打包本地编译，如果win开发ios需要打包基座。

使用时,如果是进入页面建议在安桌端延迟下显示避免生成过快获取不到当前窗口的dpr导致大小可能异常,也有助于防止卡页面.

### ref方法

通过ref方法getQrcodePath()可以得到当前qr码的本地图片路径,
每调用一次保存一次码图片,建议不要循环调用,会一直保存在缓存目录中.
* 安卓,ios返回的是缓存路径string,空子符表示失败
* web返回的是Blob文件对象或者null,如果为null表示失败.

### 属性

* foregroundColor:前景色,请使用16进制颜色
* backGroundColor:背景色,请使用16进制颜色
* content:编码内容
* logo:中间logo图片地址,如:/static/logo.png,不要太大否则安卓会失败

```ts
// 在data中添加变量
export default {
	data() {
		return {
			urls2:"的原生插件附赠插件",
		};
	},
	methods: {
		
	},
}
// 添加组件,width,height是改变码的大小，style上的宽和高仅仅是预览区域大小不会影响码的大小。
<x-qr-u ref="qr" :content="urls2" :width="120" :height="120" style="width:120px;height:120px"></x-qr-u>
let el = (this.$refs['qr'] as XQrUElement)
//获取当前码的图片路径,用于分享或者保存之类的.
let qrpath = el.getQrcodePath()

```