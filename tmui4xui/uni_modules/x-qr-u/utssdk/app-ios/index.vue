<template>
	<view class="defaultStyles">
	</view>
</template>
<script lang="uts">
	/**
   * 作者：tmzdy
   * 关联：tmui4.0
   * 参考文献：https://developer.apple.com/documentation/coreimage/cifilter/3228262-qrcodegenerator
   * 开源插件：https://github.com/EFPrefix/EFQRCode/blob/main/README_CN.md
   */

	import { UIButton, UIControl, UIImage, UIView, UIImageView, UIImageWriteToSavedPhotosAlbum, UIGraphicsImageRenderer } from "UIKit";
	import { CIFilter, CIContext } from "CoreImage";
	import { CGSize, CGRect, CGImage, CGContext } from "CoreGraphics";
	import { UTSComponent, UTSiOS } from "DCloudUTSFoundation"
	import { Bool, String } from "Swift"
	import * as EFQRCode from "EFQRCode"
	import { EFInputCorrectionLevel, EFQRCodeGenerator, EFIntSize, EFPointShape, EFPointStyle, EFCirclePointStyle } from "EFQRCode"
	import { URL, FileManager, NSAttributedString } from 'Foundation';
	import { CGPoint, CGSize, CGRect, CGFloat } from 'CoreFoundation';

	export default {
		data() {
			return {
				imgview: null as null | UIImageView
			};
		},
		/**
		 * 组件名称，也就是开发者使用的标签
		 */
		name: "x-qr-u",


		props: {
			width: {
				type: Number,
				default: 300
			},
			height: {
				type: Number,
				default: 300
			},
			// type:{
			// 	type:String as PropType<BARCODEFORMAT>,
			// 	default:"QR_CODE"
			// },
			/**
			 * 留白内边距
			 */
			margin: {
				type: Number,
				default: 2
			},
			/**
			 * 前景色
			 */
			foregroundColor: {
				type: String,
				default: '#000000'
			},
			/**
			 * 背景景色
			 */
			backGroundColor: {
				type: String,
				default: '#FFFFFF'
			},
			/**
			 * 码的内容
			 */
			content: {
				type: String,
				default: 'https://xui.tmui.design'
			},
			/**
			 * logo图片地址,请使用静态
			 */
			logo: {
				type: String,
				default: ""
			},
			/**
			 * 是否是圆点
			 */
			dotRound: {
				type: Boolean,
				default: true
			}
		},
		/**
		 * 组件内部变量声明
		 */

		/**
		 * 属性变化监听器实现
		 */
		watch: {
			"content": {
				/**
				 * 这里监听属性变化，并进行组件内部更新
				 */
				handler(newValue : String, oldValue : String) {
					this.qrCode();
				},
				/**
				 * 创建时是否通过此方法更新属性，默认值为false
				 */
				immediate: true
			},
		},




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
		NVLoad() : UIImageView {
			let uiimgview = new UIImageView()

			this.imgview = uiimgview
			return uiimgview
		},

		/**
		 * 原生View已创建
		 * [可选实现]
		 */
		NVLoaded() {
			this.qrCode();
		},
		methods: {
			
			savePhotoTocache(image : UIImage) : string {

				let fileid = Math.random().toString(16).substring(2, 11);

				let userDir = FileManager.default.urls(for = FileManager.SearchPathDirectory.cachesDirectory, in = FileManager.SearchPathDomainMask.userDomainMask).first!
				let filename = fileid + '.jpg';
				let destinationURL = userDir.appendingPathComponent(filename)
				let imageData = image.jpegData(compressionQuality = 1);

				let real = UTSiOS.try(imageData!.write(to = destinationURL), "?");
				if (real == null) return ""
				return destinationURL.path
			},

			/**
			 * 获取qr码的缓存文件路径
			 */
			getQrcodePath() : string {
				if (this.imgview == null) return ""
				let img : UIImageView = this.imgview!;
				let filestring = ""
				let image = img.image;
				if (image == null) return ""
				try {
					filestring = this.savePhotoTocache(image!)
					// 保存到ios相册,用于测试是否图片正确.
					// UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
				} catch (e) {
					console.log(e)
				}
				return filestring;
			},
			qrCode() {
				let context = CIContext()

				let datas = new String(this.content)
				let logoimg : null | CGImage = null;

				if (this.logo != '') {
					let imgpath = UTSiOS.convert2AbsFullPath(this.logo)
					let img = new UIImage(contentsOfFile = imgpath);
					logoimg = img!.cgImage

				}
				let dpr = 9

				let iconsisze = Math.ceil(this.width * 0.6).toInt()


				let cimage = new EFQRCode.generate(
					for = datas,
					size = new EFIntSize(width = this.width.toInt(), height = this.height.toInt()),
					magnification = new EFIntSize(width = dpr.toInt(), height = dpr.toInt()),
					backgroundColor = UTSiOS.colorWithString(this.backGroundColor).cgColor,
					foregroundColor = UTSiOS.colorWithString(this.foregroundColor).cgColor,
					// pointStyle = EFCirclePointStyle.circle as EFPointShape,
					icon = logoimg,
					iconSize = new EFIntSize(width = iconsisze, height = iconsisze),
				)

				let img = new UIImage(cgImage = cimage!)
				this.imgview!.image = img

			}

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