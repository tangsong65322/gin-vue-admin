<template>
	<view>
	</view>
</template>
<script lang="uts">
	/**
   * 引用 iOS 系统库
   * [可选实现，按需引入]
   */
	import {
		UIButton,
		UIControl,
		UIView
	} from "UIKit"


	import { UTSComponent } from "DCloudUTSFoundation"
	import { xCamrea } from "./camrea.uts"
	const camrea = new xCamrea()
	//原生提供以下属性或方法的实现
	export default {
		data() {
			return {
				uv:null as null|UIView
			};
		},
		/**
		 * 组件名称，也就是开发者使用的标签
		 */
		name: "x-camrea-u",
		/**
		 * 组件涉及的事件声明，只有声明过的事件，才能被正常发送
		 */
		emits: [
			/**
			 * 拍照成功时触发的事件.
			 * @param {string} path - 图片地址用于上传或者本地展示
			 * 
			 */
			'take',
			/**
			 * 录制视频结束后触发,
			 * @param {string} path - 视频保存地址
			 */
			'recoder'
		],
		/**
		 * 属性声明，组件的使用者会传递这些属性值到组件
		 */
		props: {
			/**
			 * 是否保存到相册
			 */
			savePhoto:{
				type:Boolean,
				default:false
			},
			/**
			 * 摄像头朝向,默认是后置
			 * back,front
			 */
			orientation:{
				type:String,
				default:'back'
			},
			/**
			 * 是否打开闪光灯,对于orientation为back有效.
			 */
			flash:{
				type:Boolean,
				default:false
			}
		},
		/**
		 * 组件内部变量声明
		 */

		/**
		 * 属性变化监听器实现
		 */
		watch: {
			
		},
		/**
		 * 规则：如果没有配置expose，则methods中的方法均对外暴露，如果配置了expose，则以expose的配置为准向外暴露
		 * ['publicMethod'] 含义为：只有 `publicMethod` 在实例上可用
		 */
		expose: ['open','close','take','start','pause','stop'],
		methods: {
			open(){
				camrea.setCameraDir(this.orientation)
				camrea.setFlash(this.flash)
				camrea.open()
			},
			start() {
				let t = this;
				camrea.startRecoderVideo((path:string)=>{
					let map = new Map<string,string>()
					map.set('path',path+'')
					uni.setStorageSync('xCamreaVideoPath',path)
					t.$emit('recoder',map)
				})
			},
			/**
			 * 暂停录制
			 */
			pause(){
				camrea.pauseRecoderVideo()
			},
			/**
			 * 停止录制,不是关闭相机,如果不想继续录制可以执行关闭相机.
			 */
			stop(){
				camrea.stopRecoderVideo()
			},
			close(){
				camrea.close()
			},
			take(){
				let t = this;
				camrea.takePhoto((path:string)=>{
					let map = new Map<string,any>()
					map.set('path',path+'')
					uni.setStorageSync('xCamreaPhotoPath',path)
					t.$emit('take',map)
					
				},this.savePhoto)
			}
		},

		created() {

		},
		NVBeforeLoad() {
			
		},
		/**
		 * 创建原生View，必须定义返回值类型
		 * 开发者需要重点实现这个函数，声明原生组件被创建出来的过程，以及最终生成的原生组件类型
		 * [必须实现]
		 */
		NVLoad() : UIView {
			this.uv = new UIView()
			return this.uv!
		},

		/**
		 * 原生View已创建
		 * [可选实现]
		 */
		NVLoaded() {
			let t = this;
			camrea.setView(t.uv!)
		},
		/**
		 * 原生View布局完成
		 * [可选实现]
		 */
		NVLayouted() {

		},
		/**
		 * 原生View将释放
		 * [可选实现]
		 */
		NVBeforeUnload() {
			this.close()
		},
		/**
		 * 原生View已释放，这里可以做释放View之后的操作
		 * [可选实现]
		 */
		NVUnloaded() {

		},
		/**
		 * 组件销毁
		 * [可选实现]
		 */
		unmounted() { }

		/**
		 * 更多组件开发的信息详见：https://uniapp.dcloud.net.cn/plugin/uts-component.html
		 */
	}
</script>

<style>

</style>