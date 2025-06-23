<template>
	<view class="defaultStyles">
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
		UIImageView,
		UIImage
	} from "UIKit"
	import { SVGKImage } from "SVGKit"  assert { type: "implementationOnly" };
	/**
	 * 引入三方库
	 * [可选实现，按需引入]
	 *
	 * 在 iOS 平台引入三方库有以下两种方式：
	 * 1、通过引入三方库framework 或者.a 等方式，需要将 .framework 放到 ./Frameworks 目录下，将.a 放到 ./Libs 目录下。更多信息[详见](https://uniapp.dcloud.net.cn/plugin/uts-plugin.html#ios-平台原生配置)
	 * 2、通过 cocoaPods 方式引入，将要引入的 pod 信息配置到 config.json 文件下的 dependencies-pods 字段下。详细配置方式[详见](https://uniapp.dcloud.net.cn/plugin/uts-ios-cocoapods.html)
	 *
	 * 在通过上述任意方式依赖三方库后，使用时需要在文件中 import:
	 * 示例：import { LottieAnimationView, LottieAnimation, LottieLoopMode	} from 'Lottie'
	 */

	/**
	 * UTSiOS、UTSComponent 为平台内置对象，不需要 import 可直接调用其API，[详见](https://uniapp.dcloud.net.cn/uts/utsios.html)
	 */
	import { UTSComponent } from "DCloudUTSFoundation"
	import { Data } from 'Assignables';
	import { CALayer } from 'QuartzCore';
	import { CGRect } from 'CoreFoundation';

	//原生提供以下属性或方法的实现
	export default {
		data() {
			return {
				imageView:new UIImageView()
			};
		},
		/**
		 * 组件名称，也就是开发者使用的标签
		 */
		name: "x-svg-u",

		/**
		 * 属性声明，组件的使用者会传递这些属性值到组件
		 */
		props: {
			"src": {
				type: String,
				default: ""
			},
			"width": {
				type: Number,
				default: 18
			},
			"height": {
				type: Number,
				default: 18
			},
			"color": {
				type: String,
				default: "#000000"
			}
		},
		/**
		 * 组件内部变量声明
		 */

		/**
		 * 属性变化监听器实现
		 */
		watch: {
			"src": {
				handler(newValue : String, oldValue : String) {
					if (newValue != '') {
						this.setImage(newValue)
					}
				},
				immediate: true
			},
			"width": {
				handler(newValue : Number, oldValue : Number) {
					this.setImage(this.src)
				},
				immediate: false
			},
			"height": {
				handler(newValue : Number, oldValue : Number) {
					this.setImage(this.src)
				},
				immediate: false
			},
		},

		methods: {
			setImage(newval : string) {
				if (newval != '') {
					let url = UTSiOS.getResourcePath(newval)
					let width = (this.width).toInt();
					let height = (this.height).toInt();
					this.$el.frame =  new CGRect(x = 0, y = 0, width = width, height = height)
					this.imageView.frame = this.$el.frame;
					let svgURL = new URL(fileURLWithPath = url)
					let svgData = UTSiOS.try(new Data(contentsOf = svgURL),"?")
					if(svgData==null) return;
					let svgImage = new SVGKImage(data =  svgData!)
					svgImage!.size = new CGSize(width= width, height= height)
					this.imageView.image = svgImage?.uiImage
				}
			}
		},

		/**
		 * 组件被创建，组件第一个生命周期，
		 * 在内存中被占用的时候被调用，开发者可以在这里执行一些需要提前执行的初始化逻辑
		 * [可选实现]
		 */
		created() {

		},
		/**
		 * 对应平台的view载体即将被创建，对应前端beforeMount
		 * [可选实现]
		 */
		NVBeforeLoad() {

		},
		/**
		 * 创建原生View，必须定义返回值类型
		 * 开发者需要重点实现这个函数，声明原生组件被创建出来的过程，以及最终生成的原生组件类型
		 * [必须实现]
		 */
		NVLoad() : UIView {
			let view = new UIView()
			view.addSubview(this.imageView)
			return view
		},

		/**
		 * 原生View已创建
		 * [可选实现]
		 */
		NVLoaded() {
			/**
			 * 通过 this.$el 来获取原生控件。
			 */
			// this.$el.setTitle(this.buttontext, for = UIControl.State.normal)
			this.setImage(this.src)
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
		NVBeforeUnload() { },
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