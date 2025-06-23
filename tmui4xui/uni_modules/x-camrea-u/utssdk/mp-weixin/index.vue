<template>
	<view>
		<camera style="width100%;height:100%" mode="normal" resolution="high" :device-position="orientation"
			:flash="flashMode"></camera>
	</view>
</template>
<script lang="uts">
	export default {
		data() {
			return {
				takeModelType: 'photo', //photo,video
				flashMode: "auto",
				orientationMode: "back",
				maxTimeout: 30,
				timeId: 25
			}
		},
		name: "x-camrea-u",
		emits: [
			"take",
			/**
			 * 录制视频结束后触发,
			 * @param {string} path - 视频保存地址
			 */
			'recoder'
		],
		props: {
			/**
			 * 是否保存到相册
			 */
			savePhoto: {
				type: Boolean,
				default: false
			},
			/**
			 * 摄像头朝向,默认是后置
			 * back,front
			 */
			orientation: {
				type: String,
				default: 'back'
			},
			/**
			 * 是否打开闪光灯,对于orientation为back有效.
			 */
			flash: {
				type: Boolean,
				default: false
			}
		},
		/**
		 * 属性变化监听器实现
		 */
		watch: {
			flash() {
				this.flashMode = this.flash ? 'on' : 'off'
			},
			orientation() {
				this.orientationMode = this.orientation
			}
		},
	
		NVLoad() : any {
			return null;
		},
		NVLayouted() {
			this.flashMode = this.flash ? 'on' : 'off'
			this.orientationMode = this.orientation
		},
		NVBeforeUnload() {
			this.close()
		},
		methods: {
			open() {
				this.takeModelType = 'photo'
			},

			start() {
				this.takeModelType = 'video'
				const ctx = wx.createCameraContext()
				let t = this;
				clearTimeout(this.timeId)
				ctx.startRecord({
					quality: 'high',
					timeout: 5 * 60,
					timeoutCallback(ok) {
						t.onsuccessRcoderVideo(ok)
					},
					success: (res) => {
						t.timeId = setTimeout(function () {
							t.stop()
						}, (4 * 60 + 57)*1000);
					},
					fail(er){
						console.error(er)
					}
				})

			},
			onsuccessRcoderVideo(obj : any) {
				this.$emit('recoder', {'path':obj.tempVideoPath||""})
			},
			pause() {

			},
			stop() {
				const ctx = wx.createCameraContext()
				let t = this;
				clearTimeout(this.timeId)
				ctx.stopRecord({
					compressed: true,
					timeout: 5 * 60,
					success(ok) {
						t.onsuccessRcoderVideo(ok)
					},
					fail(er){
						console.error(er)
					}
				})

			},
			take() {
				const ctx = wx.createCameraContext()
				let t = this;
				ctx.takePhoto({
					quality: 'high',
					success: (res) => {
						t.$emit('take', {'path':res.tempImagePath})
					},
					fail(er){
						console.error(er)
					}
				})
			},
			close() {
				this.stop()
			}


		}
	}
</script>