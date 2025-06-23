<template>
	<view :id="id">

	</view>
</template>
<script lang="uts">
	import Zxing from "./zxing.js"

	var resultQr = ""
	let uuid = Date.now().toString()
	export default {
		data() {
			return {
				id: uuid,
				video: null as null | HTMLElement,
				qre: null,
				cid : null
			}
		},
		name: "x-mlkit-scannig-u",
		emits: ["scan", "clickQr"],
		// 创建组件对应的原生 View，返回值类型需要修改为实际 View 类型
		NVLoad() : HTMLElement {
			return document.createElement("div") as HTMLElement
		},
		NVLayouted() {
		},
		NVBeforeUnload() {
			cancelAnimationFrame(this.cid)
		},
		methods: {
			openCamera() {
				let t = this;
				t.qre = null;
				resultQr = ""

				function scanning() {
					t.closeCamera()
					let parentView = document.getElementById(uuid)
					let video : HTMLVideoElement = document.createElement("video")
					video.style.width = "100%"
					video.style.height = "100%"
					video.style.objectFit = "cover"
					t.video = video;

					parentView!.appendChild(video)
					const canvas = document.createElement('canvas');
					const ctx = canvas.getContext('2d')!;
					navigator.mediaDevices.getUserMedia({ video: true })
						.then(stream => {
							video.srcObject = stream;
							t.qre = stream
							video.play();
							var newWidth = 800;
							var newHeight =  newWidth*video.offsetWidth / video.offsetHeight;
							
							canvas.width = newWidth
							canvas.height = newHeight
							function readFrame() {
								ctx.clearRect(0,0,newWidth,newWidth)
								ctx.drawImage(video, 0, 0, newWidth, newHeight);
								const frameData = ctx.getImageData(0, 0, newWidth, newWidth);
								
								let code = Zxing(frameData.data,newWidth,newWidth,{inversionAttempts:true})
								if(code&&code?.data&&resultQr==''){
									resultQr = code.data
									t.$emit("scan", [code.data])
									cancelAnimationFrame(t.cid)
								}
							
								t.cid = requestAnimationFrame(readFrame);
							}
							// 开始读取帧
							readFrame();
						})
						.catch(error => {
							console.error('Error accessing media devices:', error);
						});

				}
				scanning()
			},
			chooseImage() {
				let t = this;
				function scanning() {
					uni.chooseImage({
						sourceType:["album"],
						success(res) {
							if (res.tempFilePaths.length > 0) {
								let img = new Image()
								img.src = res.tempFilePaths[0];
								img.onload = function () {
									close();
									var newWidth = 600;
									var newHeight =  newWidth*img.width / img.height;
									var canvas = document.createElement('canvas');
									canvas.width = 600;
									canvas.height = 600;
									var ctx = canvas.getContext('2d');
									ctx.clearRect(0, 0, newWidth, newHeight)
									ctx.drawImage(img, 0, 0, newWidth, newHeight)
									var imageData = ctx.getImageData(0, 0, 600, 600);
									let code = Zxing(imageData.data,600,600,{inversionAttempts:true})
									if(code&&code?.data){
										t.$emit("scan", [code.data])
									}else{
										t.$emit("scan", [])
									}
								}
							}
						}
					})
				}

				scanning()
			},
			closeCamera() {
				let t = this;
				let parentView = document.getElementById(uuid)
				parentView!.innerHTML = ""
				if (t.qre) {
					t.video?.pause();
					// 停止所有轨道
					this.qre.getTracks().forEach(function (track) {
						track.stop();
					});
				}
				resultQr = ""
			}
		},




	}
</script>