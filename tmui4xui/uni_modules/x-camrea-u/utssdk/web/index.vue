<template>
	<view :id="id">

	</view>
</template>
<script lang="uts">
	export default {
		data() {
			return {
				id: Date.now().toString(),
				video: null as null | HTMLElement,
				stream: null as any,
				takeModelType: 'photo', //photo,video
				mediaRecorder: null as null | MediaRecorder
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
		// 创建组件对应的原生 View，返回值类型需要修改为实际 View 类型
		NVLoad() : HTMLElement {
			return document.createElement("div") as HTMLElement
		},
		NVLayouted() {
		},
		NVBeforeUnload() {
			this.close()
		},
		methods: {
			open() {
				this.takeModelType = 'photo'
				this._crateCamera();
			},
			async _crateCamera() {
				let t = this;
				t.close()
				let parentView = document.getElementById(t.id)
				let video : HTMLVideoElement = document.createElement("video")
				video.style.width = "100%"
				video.style.height = "100%"
				video.style.objectFit = "cover"
				parentView!.appendChild(video)
				t.video = video;
				var constraints = {
					audio: false, video: {
						width: 1920, height: 1080,
						// facingMode:this.orientation=='front'?"user":{ exact: "environment" }
					}
				};
				let devices = await navigator.mediaDevices.enumerateDevices()
				let videoDevices = devices.filter(
					(device) => device.kind === 'videoinput'
				);

				if (videoDevices.length == 0) {
					uni.showModal({
						title: "警告",
						content: "没有找到可用的摄像设备",
						showCancel: false,
						confirmText: "关闭"
					})
					return;
				}


				window.navigator.mediaDevices
					.getUserMedia(constraints)
					.then(function (mediaStream) {
						t.stream = mediaStream
						video.srcObject = t.stream;
						video.onloadedmetadata = function (e) {
							video.play();
							if (t.takeModelType == 'video') {
								t.createMediaRecorder(mediaStream)
							}
						};

					})
					.catch(function (err) {
						console.log(err.name + ": " + err.message);
						t.close()
					});
			},
			start() {
				if (this.mediaRecorder?.state == 'recording') {
					return;
				}
				if (this.mediaRecorder?.state == 'paused') {
					this.mediaRecorder?.resume()
					return;
				}

				this.takeModelType = 'video'
				this._crateCamera()
			},
			createMediaRecorder(stream) {
				if (!MediaRecorder.isTypeSupported('video/mp4')) {

					this.$emit('recoder', new Map<string, string>([['path', '']]))
					return;
				}
				const options = { mimeType: 'video/mp4' }; // 默认格式为 WebM
				this.mediaRecorder = new MediaRecorder(stream, options);

				let chunks = [];

				this.mediaRecorder!.ondataavailable = (event) => {
					if (event.data.size > 0) {
						chunks.push(event.data);
					}
				};
				let t = this;
				this.mediaRecorder!.onstop = () => {
					// 将录制的片段合并为 Blob 对象
					const blob = new Blob(chunks, { type: 'video/mp4' });
					chunks = [];
					const dataURL = URL.createObjectURL(blob)
					this.$emit('recoder', { 'path': dataURL })
				};
				this.mediaRecorder!.onerror = () => {
				
					this.$emit('recoder', { 'path': '' })
				}
				this.mediaRecorder!.start()
			},
			pause() {
				this.mediaRecorder?.stop();
			},
			stop() {
				if (this.mediaRecorder != null) {
					this.mediaRecorder.stop()
				}
			},
			take() {
				let t = this;
				if (!t.video || !t.stream) return "";
				var canvas = document.createElement('canvas');
				canvas.width = t.video.videoWidth; // 设置canvas的宽度为视频的宽度
				canvas.height = t.video.videoHeight; // 设置canvas的高度为视频的高度
				var ctx = canvas.getContext('2d');
				ctx!.drawImage(t.video, 0, 0, canvas.width, canvas.height);
				canvas.toBlob((data) => {
					const dataURL = data ? URL.createObjectURL(data) : ""
					t.$emit('take', { 'path': dataURL })
				}, 'image/png', 1)
			},
			close() {
				let t = this;
				if (t.video) {
					t.video?.pause()
					t.video = null;
				}
				if (t.stream) {
					t.stream.getTracks().forEach(function (track) {
						track.stop();
					});
					t.stream = null;
				}

				let parentView = document.getElementById(t.id)

				parentView!.innerHTML = ""
				this.mediaRecorder = null;


			}


		}
	}
</script>