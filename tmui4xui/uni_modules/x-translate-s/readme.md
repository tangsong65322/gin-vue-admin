# x-translate-s
### 开发文档

1. 目前使用前需要预下载离线模型文件才可以翻译
2. 下载好后,断网也能离线翻译
3. 如果想直接预置模型或者把模型文件部署到自己服务器上,我目前仅突破了ios端,安卓端目前我还没突破限制需要在线下载好才能离线翻译
4. 翻译仅可轻量使用,不要用专业场景,因为翻译模型是把英文作为中介,再翻译到其它语种,这给翻译带来了不确定性和精确性,仅作为参考翻译使用.

### 兼容性

| IOS | Andriod | WEB |
| --- | --- | --- |
| 12+ | 5+ | - |


### 使用

如果是安卓请务必打自定义基座，如果ios：你在mac环境下配置好了环境无需打包本地编译，如果win开发ios需要打包基座。


```ts

<button @click="donloadGoogleMode">谷歌服务器下载模型</button>
<button @click="checkmode">检查模型是否存在</button>
<button @click="fanyi">翻译</button>

import { translate,checkTranslateModeDonload,downloadTranslateMode } from "@/uni_modules/x-translate-s"

	// 翻译
const fanyi = () => {
	translate(fanyitext.value,'zh','ja',(str:string)=>{
		console.log('success:',str)
	})
}
//检查模型下载情况
const checkmode = ()=>{
	// let rootdir = uni.env.SANDBOX_PATH + 'Library/Application Support/com.google.mlkit.nl.translate'
	checkTranslateModeDonload(['ja'] as string[],(result:boolean)=>{
		uni.showToast({
			title:result?"已经下载了模型":'没有下载'
		})
	})

}

// 下载语言
const donloadGoogleMode = ()=>{
	downloadTranslateMode('zh','ja',(ok:boolean)=>{
		console.log('downloadn:',ok?'Ok':'Fail')
	})
}

```
