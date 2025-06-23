# x-runstart-logo
### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

设置应用启动时的界面,暂不能设置背景图,只可设置logo图放到static目录即可.

### 说明
这是tmui4.0|XUI的原生插件附赠插件

### 兼容性

| IOS | Andriod | WEB |
| --- | --- | --- |
| 支持 | 支持 | 支持 |

### 使用

如果是uniapp应用需要自定基座,uniappx不需要定义基座,但win开发ios时需要
如果是mac开发uniappx不需要基座

**使用时请在app.vue中onLaunch内直接执行方法显示,建议配合xmodals使用.**

### 注意
经过测试,在ios端,注入后,可以覆盖任意页面,就是你页面跳转不同页面也没关系,始终会覆盖所有页面.

但在安卓端因为版本不同需要不同的权限,还可能导致应用无法审核上架到googleplay中,因此我不打算采用特殊方法实现所有页面(显示时,你又跳转了页面)
因此安卓要实现ios那样的功能我的建议是如下:

安卓可以自己使用一个mins混淆到onLoad中这样初始运行时不管跳转到哪个页面都显示这个弹层并覆盖页面.当你确实要关闭时当前弹层.并写入本地值.
然后在onShow中读取此值判断已弹出的层(就是页面被打开过的层,没执行过当然不需要关闭了)

下面是一个示例.

```ts
import { XRUN_START_LOGO_OPTS, showRunLogo, hideRunLogo } from "@/uni_modules/x-runstart-logo"
import { showModal, X_MODAL_TYPE } from "@/uni_modules/x-modal-s"

let tonyixie = uni.getStorageSync('xTmui4.0Xieyi')
let imgsrc = 'static/logo.png'
		
showRunLogo({
	bgColor: '#006deb',
	logo: imgsrc,
	width: 60,
	height: 60,
	logoPadding: 20,
	round: 14,
	logoBgColor: '#ffffff',
	rightText: 'tmui4.0x / 2024 by tmzdy',
	fontSize: 11,
	fontColor: '#ffffff'
} as XRUN_START_LOGO_OPTS)

if (tonyixie != 'true') {
	showModal({
		title: "隐私政策", content: "我同意《TMUIX4.0使用协议》我确认我使用的是正版tmuix4.0组件及附带插件软件,并承担相应法律风险,同意请点我同意,不同意请点不同意终止访问.",
		cancelText: '不同意',
		confirmText: "我同意",
		clickMaskClose:false,
		confirm() {
			uni.setStorageSync('xTmui4.0Xieyi', 'true')
			setTimeout(function () {
				hideRunLogo()
			}, 1000);
		},
		cancel() {
			
			// #ifdef APP-ANDROID
			uni.exit()
			// #endif

		}
	} as X_MODAL_TYPE)
} else {
	hideRunLogo()
}

```
**类型参考**

```ts
export type XRUN_START_LOGO_OPTS = {
	/** 启动界面背景色,不能使用颜色名称 */
	bgColor:string,
	/** logo图片,放到static目录,也可以是网络图片地址 */
	logo:string,
	/** logo宽 */
	width:number,
	/** logo高 */
	height:number,
	/** logo容器圆角 */
	round:number,
	/** logo容器背景,不能使用颜色名称 */
	logoBgColor:string,
	/** logo下方文字 */
	rightText:string,
	/** 文字字号 */
	fontSize:number,
	/** 文字颜色,不能使用颜色名称 */
	fontColor:string,
	/** logo容器的padding */
	logoPadding:number
}
```