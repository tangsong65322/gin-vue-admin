<template>
	<view>

	</view>
</template>
<script lang="uts">
	import Context from 'android.content.Context'
	import LinearLayout from 'android.widget.LinearLayout';
	import ViewGroup from 'android.view.ViewGroup';
	import View from 'android.view.View';
	import ImageView from "android.widget.ImageView"

	import Bitmap from "android.graphics.Bitmap"
	import Color from "android.graphics.Color"

	import ByteArrayOutputStream from 'java.io.ByteArrayOutputStream'
	import Base64 from 'java.util.Base64'
	import AwesomeQRCode from 'com.github.sumimakito.awesomeqr.AwesomeQRCode'
	import Renderer from 'com.github.sumimakito.awesomeqr.AwesomeQRCode.Renderer'
	import BitmapFactory from 'android.graphics.BitmapFactory';
	import File from 'java.io.File';
	import FileOutputStream from 'java.io.FileOutputStream';
	import BitmapDrawable from 'android.graphics.drawable.BitmapDrawable';




	function px2dp(n : number) : number {

		const mets = UTSAndroid.getAppContext()!.resources!.getDisplayMetrics()

		return mets.density * n
	}


	export default {
		name: "x-qr-u",
		data() {
			return {
				CBOX: null as null | LinearLayout,
				qrImgView: null as null | ImageView
			}
		},
		props: {
			width: {
				type: Number,
				default: 100
			},
			height: {
				type: Number,
				default: 100
			},
			type: {
				type: String,
				default: "QR_CODE"
			},
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
		NVLoad() : LinearLayout {

			let grop = new LinearLayout(this.$androidContext)

			this.CBOX = grop;
			return grop
		},
		NVLayouted() {
			let width = Math.ceil(px2dp(this.width))
			let height = width
			this.createCode(this.content, width, height, this.margin, this.type, this.foregroundColor, this.backGroundColor);
			
		},

		watch: {
			content(newV : String) {
				let width = Math.ceil(px2dp(this.width))
				let height = width
				this.createCode(newV, width, height, this.margin, this.type, this.foregroundColor, this.backGroundColor);
			}
		},

		methods: {
			
			savePhotoTocache(img : Bitmap) : string {
				let context = UTSAndroid.getAppContext()!
				let filepath = context.getExternalCacheDir()?.getPath() ?? ""
				let fileid =  Math.random().toString(16).substring(2, 11);
				let file = new File(filepath, fileid+ '.jpg');
				let fos = new FileOutputStream(file)
				img.compress(Bitmap.CompressFormat.JPEG,100, fos);
				return file.getPath()
			},
			/**
			 * 获取qr码的缓存文件路径
			 */
			getQrcodePath() : string {
				let filename = Math.random().toString(16).substring(2, 11)
				if (this.qrImgView == null) return ""
				let imgview : ImageView = this.qrImgView!;
				let bitmap:Bitmap = (imgview.getDrawable() as BitmapDrawable).getBitmap()
				let filestring =  ""
				try{
					filestring = this.savePhotoTocache(bitmap)
				}catch(e){
					
				}
			
				return filestring;
			},
			/**
			 * 创建qr码
			 * @param {String} code - 码的内容
			 * @param {number} width - 码的宽度
			 * @param {number} height - 码的高度
			 * @param {number} margin - 码的边距
			 * @param {BARCODEFORMAT} type - 码的格式
			 * @param {string} ForegroundColor - 码的前景色
			 * @param {string} backGroundColor - 码的背景色
			 */
			createCode(
				code : String,
				width : number = 100,
				height : number = 100,
				margin : number = 1,
				type : string = 'QR_CODE',
				ForegroundColor : string = "#000000",
				backGroundColor : string = '#FFFFFF'
			) {
				if (this.CBOX == null) return;
				let images = new ImageView(this.$androidContext)
				if (this.qrImgView != null) {
					images = this.qrImgView!
				} else {
					this.qrImgView = images
					this.CBOX!.addView(images)
				}
				let _this = this;
				class qrCallbac extends AwesomeQRCode.Callback {
					override onRendered(renderer : Renderer, bitmap : Bitmap) {
						images.setImageBitmap(bitmap)
					}

					override onError(renderer : Renderer, e : Exception) { }
				}
				let logoimg : null | Bitmap = null;

				if (this.logo != '') {
					let imgpath = UTSAndroid.convert2AbsFullPath(this.logo)
					logoimg = BitmapFactory.decodeFile(imgpath)
				}
				AwesomeQRCode
					.Renderer()
					.contents(code)
					.roundedDots(this.dotRound)
					.colorLight(Color.parseColor(backGroundColor))
					.colorDark(Color.parseColor(ForegroundColor))
					.dotScale((1).toFloat())
					.size(width.toInt())
					.margin(margin.toInt())
					.logo(logoimg)
					.logoScale((0.25).toFloat())
					.renderAsync(new qrCallbac())

			}
		}
	}
</script>