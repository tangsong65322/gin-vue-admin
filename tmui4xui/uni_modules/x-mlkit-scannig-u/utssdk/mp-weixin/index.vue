<template>
	<view :id="uid2">
		<camera v-if="isOpenScan"  style="width100%;height:100%" mode="scanCode" device-positio="back"
			flash="auto" @scancode="scancodeEvt"  @error="scanError" ></camera>
	</view>
</template>
<script lang="uts">
	import Zxing from "./zxing.js"

	export default {
		data() {
			return {
				uid: "xcanvas" + Date.now(),
				uid2: "xcanvas2" + Date.now(),
				resultQr: "",
				flashMode: "off",
				orientationMode: "back",
				isOpenScan: false
			}
		},
		name: "x-mlkit-scannig-u",
		emits: ["scan", "clickQr"],
		props: {
			orientation:{
				type:String,
				default:"back"
			},
			/**
			 * 是否打开闪光灯,对于orientation为back有效.
			 */
			flash: {
				type: Boolean,
				default: false
			}
		},
		NVLoad() : any {
			return null;
		},
		NVLayouted() {
			this.flashMode = this.flash ? 'on' : 'off'
	
		},
		NVBeforeUnload() {
		},
		watch:{
			flash(newvalue){
				this.flashMode = newvalue ? 'on' : 'off'
			}
		},
		methods: {
			
			scanError(e){
				console.error(e)
			},
			scancodeEvt(evt) {
				const qrdata = evt.detail.result;
				if(this.resultQr==""){
					this.resultQr = qrdata
					this.$emit("scan",[qrdata])
				}
			},
			openCamera() {
				this.isOpenScan = true;
			},
			chooseImage() {
				let t = this;

				uni.chooseImage({
					sourceType:["album"],
					async success(res) {
						if(res.tempFilePaths.length == 0) return
						wx.compressImage({
							src:res.tempFilePaths[0],
							compressedWidth:600,
							async success(res2) {
								let imgpath = res2.tempFilePath
								
								const canvas = wx.createOffscreenCanvas({
									type: "2d",
									width: 400,
									height: 400
								}, this)
								
								// 创建一个图片
								const image = canvas.createImage()
								// 等待图片加载
								await new Promise(resolve => {
									image.onload = resolve
									image.src = imgpath
								})
								let width = 400
								let height = width*image.width / image.height
								const context = canvas.getContext('2d')
								
								// 把图片画到离屏 canvas 上
								context.clearRect(0, 0, width, height)
								context.drawImage(image, 0, 0, width, height)
								// 获取画完后的数据
								const imageData = context.getImageData(0, 0, 400, 400)
								// https://www.npmjs.com/package/jsqr-es6
								let code = new Zxing(imageData.data,400,400,{inversionAttempts:true})
								if(code&&code?.data){
									t.$emit("scan", [code.data])
								}else{
									t.$emit("scan", [])
								}
							}
						})
						
						
					}
				})


			},
			closeCamera() {
				this.isOpenScan = false;
				this.resultQr = ""
			}


		}
	}
</script>