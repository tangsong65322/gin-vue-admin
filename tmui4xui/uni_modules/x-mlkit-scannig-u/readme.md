# x-mlkit-scannig-u
### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

### 功能特色

1. ios,安卓是Ai模型识别速度非常快，大概ios:50-100ms,安卓：200-350ms
2. web/h5带摄像头，实时识别时，效率比较低，识别精度不高，要多对几次
3. web/微信图片识别时，精度中上。（不依赖微信官方，也不依赖Uniapp官方纯像素插件识别），不要图片了好多码，识别不准，如果码是黑色，多码能识别一个
如果多码是非黑色，可能识别不出来
4. 嵌入式页面识别，方便自己布局和装饰扫码界面。
5. 微信，web只能是单码识别，多码一起识别不精准

**嵌入式相机识别在微信端：微信官方的本身这个组件就有很多问题，如果遇到没有扫码结果，请自行向微信官方提问，不需要问我，我的xs max就没有任何响应，但安卓有**
**最主要的更新是兼容了微信，并支持微信自定图片识别，这样可以不用打开微信自带的界面再选择图片识别，给了大家商用非常好的便利**
**web,微信图片识别时，请注意图片的干净，尽量不要多码放一起，一图一码，识别精准度还是好的**

### 兼容性

| IOS | Andriod | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 使用

如果是安卓请务必打自定义基座，如果ios：你在mac环境下配置好了环境无需打包本地编译，如果win开发ios需要打包基座。

```ts

// 添加组件
<x-mlkit-scannig-u
@clickQr="onclickQr"
@scan="saningEvent"
 :autoOpenCamera="false"
 :cameraWidth="1080" :cameraeiHght="1080" style="width:750rpx;height:750rpx;background:black" 
 ref="XscanU">
 </x-mlkit-scannig-u>
 
 
export default {
	data() {
		return {
			result:[] as string[],
			apiStr:""
		};
	},
	methods: {
		saningEvent(str:string[]){
			// #ifdef APP-ANDROID||WEB||MP

			this.result = str as string[];
			// #endif
			// #ifdef APP-IOS

			let resultstr = uni.getStorageSync("xMlKITScaning")
			if(resultstr!=null){
				let result = JSON.parseArray<string>(resultstr as string)
				this.result = result
			}

			// #endif
		},
		onclickQr(str:string){
			// #ifdef APP-ANDROID||WEB||MP
			uni.showModal({
				title:"提醒",
				content:str,
				showCancel:false
			})
			// #endif
			// #ifdef APP-IOS
			let resultstr = uni.getStorageSync("xMlKITScaningClick")
			uni.showModal({
				title:"提醒",
				content:resultstr,
				showCancel:false
			})
			// #endif
		},
		openCamera(){
			let el = (this.$refs['XscanU'] as XMlkitScannigUElement)
			el.openCamera()
		},
		//通过相册选取图片识别.
		choose(){
			let el = (this.$refs['XscanU'] as XMlkitScannigUElement)
			el.chooseImage()
		},
		closeCamera(){
			let el = (this.$refs['XscanU'] as XMlkitScannigUElement)
			el.closeCamera()
		}
	},
	
}

```