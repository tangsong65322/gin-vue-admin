# x-file-s
### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

**如果需要查看效果请[下载TMUI4.0组件库应用demo](https://ext.dcloud.net.cn/plugin?id=16369)，导航到原生插件栏目体验。**

### 功能特色

** 本插件是API接口插件非组件，插件截图是我的TMUI4.0 x-upload-file基于此api接口封装的ui组件 **

- 支持安卓，无权限操作
- 支持web选择文件上传
- 支持多选，单选
- 支持微信

### 功能说明

**请仔细看下面的使用方法，ios和web,安卓有区别注意条件编译进上传上传**
- 安卓端无需权限，返回系统的文件列表，但不包含真实文件地址。如果需要操作上传读取等，需要配置copyFileToPath方法,生成一个你自己的文件缓存目录。把文件复制到此位置。
- 如果不要用了，要自己通过官方uni.getFileSystemManager来管理和清空缓存文件夹。不然应用随意使用的推移会增大。
- web端直接选择上传没有上述问题
- ios已支持从系统文件 管理器选择任意文件上传，它同安卓一样会在选择的时候copy一份文件到应用专属缓存文件中（不用担心变大，会自动清除），选择的文件只能当即临时上传
时间长了会自动删除。返回的文件路径需要自行uni.env.CACHE_PATH + "/" + item.realFilePath组合路径进行上传

- 如果你不会使用，建议使用我的tmui4.0组件中的x-upload-file，它是基于此api接口封装的上传组件，啥都帮你配置好了，你只要提供个服务器的上传地址。


### 兼容性

| IOS | Andriod | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 说明
这是tmui4.0|XUI的原生插件附赠插件。种子用户可免于购买。

非种子用户：

普通授权：99元
源码授权：199元

### 使用
如果你需要32位系统和模拟器x86上运行，需要自行配置打包cpu 支持类型，配置abis
需要自定义基座运行，且安卓4.4+（含4.4）以上支持

```ts
// 导入
import {xFileSystem,fileListType} from "@/uni_modules/x-file-s"

/**
 * 新建文件管理对象，
 * typeFilter:string|null 文件过滤器例："*/*",或者所有图片 "image/*"
 * tempmultiple:boolean|null 是否多选，默认是
 * maxSize:number|null 限制的文件大小，不是禁止用户选中，是返回的列表会标stauts=4，表示超过了大小。
 */
this.xfile = new xFileSystem(null,null)

// 打开文件夹选择文件
this.xfile!.openDocument((list:any)=>{
	// 安卓是 list:fileListType[]是选中的文件列表，但这个文件列表是虚拟的，并非真实的文件地址。
	// web端list:fileListType[] 可以通过item.file访问文件对象即File
	// ios端是string
	
	let list = [] as fileListType[];
	// #ifdef APP-IOS
	let templist = JSON.parseArray<string>(listtest)
	for(let i=0;i<templist.length;i++){
		let item = JSON.parse(templist[i])! as fileListType;
		list.push(item)
	}
	// #endif

	// #ifndef APP-IOS
	list = listtest as fileListType[]
	// #endif

})

// 读取文件，为了抹平差异，web,安卓，ios编译在读取或者上传前调用以下函数获得上传的上传地址
// 上传前需要一个临时存在的路径地址，这样文件会复制到你提供的目录缓存下。因此要选创建一个临时目录
fileIsOnlyInSys( dir:string):Promise<string>{
	// #ifdef WEB
	return Promise.resolve("")
	// #endif
	//默认创建一个临时的 tmui4temp 目录
	let baseNamePath = dir==null?'tmui4temp':dir
	baseNamePath = uni.env.CACHE_PATH + "/" + baseNamePath
	const fileManager = uni.getFileSystemManager()
	return new Promise((res,rej)=>{
		fileManager.readdir({
			dirPath:baseNamePath,
			success(result:ReadDirSuccessResult){
				if(result==null){
					fileManager.mkdir({
						dirPath:baseNamePath,
						recursive:true,
						success(result:FileManagerSuccessResult){
							res(baseNamePath)
						},
						fail(er:UniError){
							console.log('创建目录失败',er)
							rej("")
						}
					}  as MkDirOptions)
				}else{
					// 这个是目录路径
					res(baseNamePath)
				}
			},
			fail(ere:UniError){
				fileManager.mkdir({
					dirPath:baseNamePath,
					recursive:true,
					success(result:FileManagerSuccessResult){
						res(baseNamePath)
					},
					fail(er:UniError){
						console.log('创建目录失败',er)
						rej("")
					}
				} as MkDirOptions)
			}
		} as ReadDirOptions)
	})
}

//调用上述方法，确保临时目录存在后通过Promise回调来复制文件路径
// web,安卓如下执行读取真实路径给uploadfile来上传
this.fileIsOnlyInSys('tmui4temp')
.then((basedir:string)=>{
	_this.xfile!.copyFileToPath(item.id,basedir)
	.then((oreal:fileListType|null)=>{
		// oreal 这个对象包含了真实的上传地址
		// 在这里面你可以读取，上传文件了。
	})
})
// ios端不需要执行上面的步骤。
// 直接就是前面的项目fileListType中的 uni.env.CACHE_PATH + "/" + item.realFilePath 组合路径进行上传



```

## 类型参考

```ts
// api内部类型。
type xFileSNameTYpe = {
	name:string,
	type:string,
	uri:Uri,
	id:string,
	realFilePath:string,
	cacheFilePath:string,
	size:number,
	status:number
}
// 你外部使用的文件对象类型
export type xFileSListType = {
	name:string,
	type:string,
	id:string,
	/** web平台文件对象 */
	file?:any,
	/** 个人用户自定数据 */
	request?:any,
	/** 安卓机/ios机下面的真实sd路径 */
	realFilePath:string,
	/** uniapp应用协议文件路径，可用uni.getFileSystemManager进行删除或者查询到 */
	cacheFilePath:string,
	/** 文件大小 */
	size?:number
	/**
	 * 0等待，1失败，2成功,3上传中,4超过大小。
	 */
	status?:0|1|2|3|4
}


```