# x-zip-s
### 开发文档

压缩和解压插件,目前仅支持zip格式.主要可以对app的数据缓存文件进行压缩,然后上传到服务器使用的场景.

### 兼容性

| IOS | Andriod | WEB |
| --- | --- | --- |
| 12+ | 5+ | - |



### 使用

如果是安卓请务必打自定义基座，如果ios：你在mac环境下配置好了环境无需打包本地编译，如果win开发ios需要打包基座。


```ts

import { addZip,unZip,addZipAndSaveDisk } from "@/uni_modules/x-zip-s"
/**
 * 压缩文件
 * target,需要压缩的目录,如:uni.env.CACHE_PATH+'/dir/'
 * filepath,添加的压缩的文件路径及名称如:uni.env.CACHE_PATH + 'test.zip'
 */
addZip(target,filepath,(pathfile:string)=>{
	//压缩成功后返回路径
	console.log(pathfile)
})
/**
 * 解压文件
 * path:待解压的文件路径
 * target:解压至目标目录
 */
unZip(path,target)

/**
 * ios专用函数,压缩成功后会直接打开系统手机
 * 存储器,提示保存到icloud或者手机文件夹,你可以通过mac电脑同步保存.
 */
// #ifdef APP-IOS
addZipAndSaveDisk(target,filepath,(pathfile:string)=>{
	console.log(pathfile)
})
// #endif

```
