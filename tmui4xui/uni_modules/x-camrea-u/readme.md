# x-camrea-u

### 特性说明

可以预览拍照,并嵌入到你的页面中直接使用.使用ref函数控制相机.

### 兼容性

| IOS | Andriod | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 开发文档
**使用注意**
打开,关闭,录制中等相关相机状态,请自行通过事件管理.
录制视频或者拍照时,如果出现错误,接受到的数据为空字符串来判断是否有误.(web正确为blob视频文件或者base64图片数据)

图片格式:jpg,png
视频格式:mp4,webm

**ref方法**
| 方法	| 参数	| 说明		|
| ---	| ---		| ---		|
| open	| -		| 打开相机,微信是自动打开为了兼容可以执行,但无效果	|
| close	| -		| 关闭相机,微信是关闭页面自动关闭相机,其它平台一定要执行	|
| take	| -		| 抓拍	|
| start	| -		| 打开相机开始录制视频	|
| pause	| -		| 暂停录制视频(ios,web,h5不支持,执行后无效果)	|
| stop	| -		| 停止录制视频(不是关闭相机)	|

**事件**
| 事件名称	| 参数	| 说明		|
| ---	| ---		| ---		|
| @take	| Map<string,string>	| get('path')为图片路径,web为base64数据	|
| @recoder	| Map<string,string>	| get('path')为视频路径,web为Blob文件对象	|


页面放置组件：
```vue
/**
 * 标签上有两个属性:
 * orientation:front,back(默认),选择前置还是后置摄像头,web不支持
 * flash:true,false,拍摄时,是否打开闪光灯,web不支持.注意使用闪光灯时,请不要使用前置摄像头.
 */
<x-camrea-u @take="getPhoto" ref="camrea" style="width:100%;height:320px"></x-camrea-u>
// 前置摄像头
<x-camrea-u orientation='front' @take="getPhoto" ref="camrea" style="width:100%;height:320px"></x-camrea-u>
// 打开闪光灯
<x-camrea-u :flash="true" @take="getPhoto" ref="camrea" style="width:100%;height:320px"></x-camrea-u>

```
选项式调用：
```ts
export default {
	data() {
		return {
			urlSrc: ''
		}
	},
	methods: {
		open() {
			let el = (this.$refs['camrea'] as XCamreaUElement)
			el.open()
		},
		close() {
			let el = (this.$refs['camrea'] as XCamreaUElement)
			el.close()
		},
		take() {
			let el = (this.$refs['camrea'] as XCamreaUElement)
			el.take()
		},
		recoder(result:Map<string,string>) {
			let src = result['path'] as string;
			if (src != '') {
				this.videoUrlSrc = src! as string;
			}
		},
		getPhoto(result:Map<string,string>) {
			let src = src = result['path'] as string;
			if (src != '') {
				this.urlSrc = src! as string;
			}
		}
	}
}

```

组合式调用：

```ts
const camrea = ref<XCamreaUElement|null>(null)
const open = ()=>{
	el.value?.open?.()
}
const close = ()=>{
	el.value?.open?.()
}
const take = ()=>{
	el.value?.open?.()
}

// 拍照的事件内获取图片路径.
const getPhoto = (result:Map<string,string>)=>{
	let src = src = result['path'] as string;
	if (src != '') {
		this.urlSrc = src! as string;
	}
}

```

参数配置：

ios组件上有属性
savePhoto:boolean 是否保存到相册(仅ios支持)
