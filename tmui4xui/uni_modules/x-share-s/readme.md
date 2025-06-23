# x-share-s
### 开发文档

通过接口简单使用可分享你的任意内容到其它app

前提：

- 需要打包时指定分享路径，请看下面的技术说明
- 安卓端请联系下载AndroidManifest.xml文件至你项目中，联系我技术支持，否则无法分享。

### tmui4.0Vip用户不需要购买已经集成在组件库中
[tmui4.0](https://ext.dcloud.net.cn/plugin?id=16369)

### 功能说明

- 安卓端可以分享任意文件，文本，视频，图片，音乐至其它app
- IOS端，支持分享任意文件到其它APP,可以分享图片，视频，音频到微信qq等等
- 文本分享到微信

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | x | x |

### 方法说明

差异说明：

- 安卓端title就是分享内容时所要展示的分享标题，但在ios端就是你的分享内容，ios端没有标题一说，系统不支持,安卓端如果同时提供了标题和content，最终分享的是content文本
- minType，如果为text/plain时，title是标题（安卓可用）,content为分享的文本内容
- minType为其它时比如图片等格式 title是标题（安卓可用）,content无用，path就是文件地址(文档，图片，视频等等任意文件)

```ts
/**
 * title:分享的标题
 * minType:分享的内容格式
 * 文本：text/plain
 * 图片：image/*
 * 音频: audio/*
 * 视频: video/*
 * 任意文件: *\/* 
 * 
*/
xShare(title : string, minType : string, content ?: string, path ?: string)

```

### 使用示例

如果是安卓请务必打自定义基座
如果是ios：你在mac环境下配置好了环境无需打包本地编译，如果win开发ios需要打包基座。

```vue
// 你的uts代码
<script>
	import { xShare } from "@/uni_modules/x-share-s"
	export default {
		data() {
			return {
				url:''
			}
		},
		methods: {
			toWxMiniApp(){
				//安卓和ios其它应用能收到内容："我要分享的文本内容",微信无法接收，但其它应用可以。
				xShare("我是标题","text/plain","我要分享的文本内容",null)
				//安卓和ios其它应用能收到图片（微信也能接收可以发送给朋友，朋友圈，用户，自己）
				xShare("我是标题","image/*",null,"img.jpg")
			}
		}
	}
<\/script>

```