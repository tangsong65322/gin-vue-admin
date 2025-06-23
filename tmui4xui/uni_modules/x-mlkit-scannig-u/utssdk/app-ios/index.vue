<template>
	<view>
	</view>
</template>
<script lang="uts">
	// import { UIView } from 'UIKit';
	import { AVCaptureSession, AVCaptureDevice, AVMediaType, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureDeviceInput, AVCaptureInput, AVCaptureVideoDataOutput, AVCaptureConnection, AVCaptureVideoPreviewLayer, AVLayerVideoGravity, AVCaptureVideoOrientation } from 'AVFoundation';
	import { PHPhotoLibrary, PHAuthorizationStatus } from 'Photos';
	import { CMSampleBuffer, CMSampleBufferGetFormatDescription, CMFormatDescription, CMVideoFormatDescriptionGetDimensions } from 'CoreMedia';
	import { DispatchQueue } from "Dispatch"
	import { UIView, UIImage, UIApplication } from 'UIKit';
	import { CGRect, CGFloat, CGPoint, CGAffineTransform } from 'CoreFoundation';
	import { Barcode, BarcodeScannerOptions, BarcodeFormat, BarcodeScanner, CMVideoDimensions } from "MLKitBarcodeScanning"
	import { VisionImage } from "MLKit"
	import { SCANNING_PHOTO_RESULT, CALL_BACK_TYPE_PRIVATE, SCANNING_PHOTO_RESULT_BOUND, SCANNING_PHOTO_RESULT_POS, AUTH_CALL_BACK_TYPE } from '../interface.uts';
	import { NotificationCenter, NSNotification, Notification } from 'Foundation';
	import { Selector } from 'ObjectiveC';

	type ConverXy = {
		x : number,
		y : number,
		minx : number,
		maxx : number,
		miny : number,
		maxy : number,
	}
	type contaiaSize = {
		width : number,
		height : number
	}
	type contaiaCalseSize = {
		scale : number,
		offsetX : number,
		offsetY : number
	}
	type contaiPointXy = {
		x : number,
		y : number
	}
	// let inputDevice : AVCaptureDeviceInput | null = null;
	// 识别结果
	let scanResult = [] as Swift.Array<Barcode>
	let captureSession : null | AVCaptureSession = null;
	// 视频宽
	let videoWidth = 0
	// 视频高
	let videoHeight = 0
	// 图像捕捉事件代理。
	let captureOutDelegate : CaptureOutSessionBuffer | null = null;
	let pointsEvents = [] as PointClickEvent[]
	let isCamreaing = false;
	export default {
		data() {
			return {
				previewLayer: null as null | UIView,
				pointView: [] as UIView[],
				avcapDev:null as null|AVCaptureDevice
			}
		},
		name: "x-mlkit-scannig-u",
		emits: ["scan", "clickQr"],
		props:{
			/**
			 * 是否开启闪光灯
			 */
			flash:{
				type:Boolean,
				default:false
			}
		},
		// 创建组件对应的原生 View，返回值类型需要修改为实际 View 类型
		NVLoad() : UIView {
			let view = new UIView();
			this.previewLayer = view

			return view
		},
		NVLayouted() {


		},
		NVBeforeUnload() {
			// 注销前关闭摄像头。
			this.closeCamera();
		},
		methods: {

			isCheckPermissions(callFun : null | AUTH_CALL_BACK_TYPE) {
				let realcall : AUTH_CALL_BACK_TYPE = (_ : boolean) => { };
				if (callFun != null) {
					let cllfunFun = callFun!;
					realcall = cllfunFun
				}

				AVCaptureDevice.requestAccess(for = AVMediaType.video, completionHandler = (isok2 : boolean) => {
					if (!isok2) {
						realcall(false)
						return;
					}
					realcall(true)
				})
			},
			/** 手动开启和关闭闪光灯 */
			setFlashModel(flash:boolean){
				if(this.avcapDev!=null){
					let islock = UTSiOS.try(this.avcapDev!.lockForConfiguration(),"?")
					if(islock!=null){
						this.avcapDev!.torchMode = flash? AVCaptureDevice.TorchMode.on : AVCaptureDevice.TorchMode.off
						this.avcapDev!.unlockForConfiguration()
					}
				}
			},
			openCamera() {
				let t = this;
				this.isCheckPermissions((auth : boolean) => {
					if (auth) {
						t.createVideo()
					}
				})

			},
			chooseImage() {
				let t = this;
				uni.chooseImage({
					count: 1,
					sourceType:['album'],
					success(evt : ChooseImageSuccess) {

						if (evt.tempFilePaths.length > 0) {
							let imgs = evt.tempFilePaths[0] as string;
							let realImgPath = imgs as string
							if(imgs.indexOf('file://')>-1){
								realImgPath = imgs.substring(7) as string;
							}
							let image = new UIImage(contentsOfFile = realImgPath);
							
							if (image != null) {
								let realimageds = image! as UIImage;

								// 图片识别码.
								let visionImage = new VisionImage(image = realimageds)
								visionImage.orientation = realimageds.imageOrientation
								
								let barcodeOptions = BarcodeScannerOptions(formats = BarcodeFormat.all)
								let barcodeScanner = new BarcodeScanner.barcodeScanner(options = barcodeOptions)
								barcodeScanner.process(visionImage, completion = (features : Swift.Array<Barcode> | null, error) => {
									
									if (features == null || error != null) {
										uni.setStorageSync("xMlKITScaning", JSON.stringify([] as string[]))
										t.$emit("scan")
										return;
									}
									if (features!.length == 0) {
										uni.setStorageSync("xMlKITScaning", JSON.stringify([] as string[]))
										t.$emit("scan")
										return;
									}

									let listpos = [] as number[][][]
									let bounedlist = [] as SCANNING_PHOTO_RESULT_BOUND[]
									let rulstText = [] as string[]

									for (let i = 0; i < features!.length; i++) {
										let barcode = features![i]
										// 位置信息
										let bounds = barcode.frame
										// 坐标
										let corners = barcode.cornerPoints
										// 解析的内容
										let rawValue = barcode.rawValue
										let iminfo = {
											width: Number(bounds.width),
											height: Number(bounds.height),
											centerX: Number(bounds.midX),
											centerY: Number(bounds.midY)
										} as SCANNING_PHOTO_RESULT_BOUND
										let posinfo = [] as number[][]
										for (pos in corners!) {
											// pos是pointValue类型并返回CGPoint，其中有x,y
											let ponit = pos.cgPointValue
											posinfo.push([Number(ponit.x), Number(ponit.y)] as number[])
										}
										listpos.push(posinfo)
										bounedlist.push(iminfo)
										rulstText.push(rawValue == null ? '' : (rawValue!))

									}
									let result = {
										url: '',
										position: listpos,
										bounds: bounedlist,
										text: rulstText
									} as SCANNING_PHOTO_RESULT

									
									uni.setStorageSync("xMlKITScaning", JSON.stringify(rulstText))
									t.$emit("scan")
								})
							} else {
								
								uni.setStorageSync("xMlKITScaning", JSON.stringify([] as string[]))
								t.$emit("scan")
							}

						} else {
							
							uni.setStorageSync("xMlKITScaning", JSON.stringify([] as string[]))
							t.$emit("scan")
						}
					},
					fail() {
						uni.setStorageSync("xMlKITScaning", JSON.stringify([] as string[]))
						t.$emit("scan")
					}
				})
			},
			closeCamera() {
				// 移除点。
				this.clearPointView()
				this.setFlashModel(false)
				if (captureSession != null) {
					captureSession!.stopRunning()

					for (input in captureSession!.inputs) {
						captureSession!.removeInput(input)
					}

					for (output in captureSession!.outputs) {
						captureSession!.removeOutput(output)
					}
					captureSession = null;
				}
				scanResult = [] as Swift.Array<Barcode>
				pointsEvents = [] as PointClickEvent[]
				this.avcapDev = null;

			},
			createPointView(result : SCANNING_PHOTO_RESULT) {

				let realCgSize = this.previewLayer!.frame as CGRect;
				let realWidth = Number(realCgSize.width);
				let realHeight = Number(realCgSize.height);
				this.clearPointView();
				// 计算视频和容器的宽高比
				let videoAspectRatio = videoWidth / videoHeight
				let containerAspectRatio = realWidth / realHeight
				let ratio_real_width = 0
				let ratio_real_height = 0
				if (videoAspectRatio > containerAspectRatio) {
					ratio_real_width = realWidth
					// 视频的宽高比大于预览层的宽高比，宽为预览宽，但高会大于预览高从而被裁剪。
					ratio_real_height = realHeight * videoAspectRatio
				} else {
					ratio_real_width = realWidth / videoAspectRatio
					ratio_real_height = realHeight
				}
				let t = this;
				let pointSize = 30
				DispatchQueue.main.async(execute = () : void => {

					for (let i = 0; i < result.bounds.length; i++) {
						let text = result.text[i]
						let bounds = result.bounds[i]
						let pos = result.position[i];
						let centerx = (pos[2][0] - pos[0][0]) / 2 + pos[0][0]
						let centery = (pos[2][1] - pos[0][1]) / 2 + pos[0][1]
						let diffTop = (realHeight - ratio_real_height) / 2
						let diffLeft = (realWidth - ratio_real_width) / 2
						let x = (ratio_real_width - ratio_real_width * (bounds.centerY / videoHeight) - diffLeft - 15).toInt()

						let y = (ratio_real_height * (bounds.centerX / videoWidth) + diffTop - 15).toInt()
						// console.log(bounds.centerX,bounds.centerY,x,y,videoWidth,videoHeight,realWidth,realHeight,ratio_real_width,ratio_real_height)
						let result = calcPoint(realWidth, realHeight, videoWidth, videoHeight, bounds.centerX, bounds.centerY)
						let rect = new CGRect(x = (result.x - 15).toInt(), y = (result.y - 15).toInt(), width = pointSize.toInt(), height = pointSize.toInt())
						let pointViewSelf = new UIView();
						pointViewSelf.layer.frame = rect;
						pointViewSelf.backgroundColor = UTSiOS.colorWithString('#21d429');
						pointViewSelf.layer.borderWidth = 2
						pointViewSelf.layer.borderColor = UTSiOS.colorWithString('#FFFFFF').cgColor;
						pointViewSelf.layer.cornerRadius = new CGFloat(pointSize / 2);

						let onlick = new PointClickEvent((atext : string) => {
							console.log("ok....", atext)
							uni.setStorageSync("xMlKITScaningClick", atext)
							t.$emit('clickQr')
						}, text);
						pointsEvents.push(onlick)
						let tapGestureCancel = new UITapGestureRecognizer()
						tapGestureCancel.addTarget(onlick, action = new Selector("onclick"))
						pointViewSelf.addGestureRecognizer(tapGestureCancel)


						this.previewLayer!.addSubview(pointViewSelf)
						this.pointView.push(pointViewSelf)

					}
				})
			},
			clearPointView() {
				DispatchQueue.main.async(execute = () : void => {
					for (let i = 0; i < this.pointView.length; i++) {
						let item = this.pointView[i];
						item.removeFromSuperview();
					}
					this.pointView = [] as UIView[]
				})
			},

			createVideo() {
				let t = this;
				isCamreaing = false;
				this.closeCamera();
				captureSession = new AVCaptureSession();
				let captureDevice = AVCaptureDevice.default(for = AVMediaType.video)
				let captureOut = new AVCaptureVideoDataOutput();

				captureSession!.sessionPreset = AVCaptureSession.Preset.photo
				let parentView = this.previewLayer!;

				captureOutDelegate = new CaptureOutSessionBuffer((result : SCANNING_PHOTO_RESULT) => {
					t.createPointView(result)
					uni.setStorageSync("xMlKITScaning", JSON.stringify(result.text))
					t.$emit("scan")
				})

				// 新建设备的输入设备
				let inputDevice = UTSiOS.try(new AVCaptureDeviceInput(device = captureDevice!), "?")
				if (inputDevice != null) {
					// 添加输入到会话中。
					captureSession!.addInput(inputDevice!)
				}
				

				captureOut.alwaysDiscardsLateVideoFrames = true;
				// 设置输出会话
				captureOut.setSampleBufferDelegate(captureOutDelegate!, queue = DispatchQueue.global())
				if (captureSession!.canAddOutput(captureOut)) {
					captureSession!.addOutput(captureOut)
					console.log("绑定输出层正确！")
				}
				
				
				DispatchQueue.main.async(execute = () : void => {
					let cameraView = new AVCaptureVideoPreviewLayer(session = captureSession!)
					// 设置预览层绑定
					// 下面的缩放会居中显示，因此左顶点可能在左上方
					cameraView.videoGravity = AVLayerVideoGravity.resizeAspectFill
					//后摄像头,设备是横向向的,显示到竖向,是顺时旋转90度.
					cameraView.connection!.videoOrientation = AVCaptureVideoOrientation.portrait
					cameraView.frame = parentView.layer.bounds;
					// 绑定渲染层。
					parentView.layer.addSublayer(cameraView)
					captureSession!.startRunning()
					t.avcapDev = captureDevice!
					t.setFlashModel(t.flash)
					// ios识别太快了，图像还没定焦就识别出来了，稍微延迟下，不要太快了。与安卓对齐 下。
					setTimeout(function () {
						isCamreaing = true;
					}, 300);
				})

			}
		}
	}

	class PointClickEvent {
		private callback : (txt : string) => void
		private text : string;
		constructor(callback : (txt : string) => void, atext : string) {
			this.callback = callback;
			this.text = atext;
			super.init()
		}

		@objc onclick() {

			this.callback(this.text)
		}
	}

	class CaptureOutSessionBuffer implements AVCaptureVideoDataOutputSampleBufferDelegate {
		callback : (str : SCANNING_PHOTO_RESULT) => void = (str : SCANNING_PHOTO_RESULT) => { }
		constructor(dv : (str : SCANNING_PHOTO_RESULT) => void) {
			this.callback = dv;
			super()
		}
		captureOutput(output : AVCaptureOutput, @argumentLabel("didOutput") sampleBuffer : CMSampleBuffer, @argumentLabel("from") connection : AVCaptureConnection) {
			if (!isCamreaing) return;
			// console.log('图片捕捉正确')
			let image = new VisionImage(buffer = sampleBuffer)
			// 这里会直接影响到测量的起始点。下面是镜像，测量是图片左上为起始，但设备是竖向，因此计算时的x,y坐标其实是相对屏幕向右转下，x,y是反向的，因为是镜像
			// 所以计算位置时，x,y是反的，宽和高也是相反的。
			image.orientation = UIImage.Orientation.upMirrored
			let barcodeOptions = BarcodeScannerOptions(formats = BarcodeFormat.all)
			// options=barcodeOptions
			let barcodeScanner = new BarcodeScanner.barcodeScanner(options = barcodeOptions)

			barcodeScanner.process(image, completion = (features : Swift.Array<Barcode> | null, error) => {

				if (features == null || error != null) {
					return;
				}
				if (features!.length == 0 || scanResult.length > 0) {
					return;
				}

				// 暂停识别。
				captureSession!.stopRunning()

				scanResult = features!
				let descVideo : CMFormatDescription | null = CMSampleBufferGetFormatDescription(sampleBuffer);
				if (descVideo != null) {
					let dimesionsize : CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(descVideo!)
					videoWidth = Number(dimesionsize.width)
					videoHeight = Number(dimesionsize.height)
				}


				let listpos = [] as number[][][]
				let bounedlist = [] as SCANNING_PHOTO_RESULT_BOUND[]
				let rulstText = [] as string[]

				for (let i = 0; i < features!.length; i++) {
					let barcode = features![i]
					// 位置信息
					let bounds = barcode.frame
					// 坐标
					let corners = barcode.cornerPoints
					// 解析的内容
					let rawValue = barcode.rawValue
					let iminfo = {
						width: Number(bounds.width),
						height: Number(bounds.height),
						centerX: Number(bounds.midX),
						centerY: Number(bounds.midY)
					} as SCANNING_PHOTO_RESULT_BOUND
					let posinfo = [] as number[][]
					for (pos in corners!) {
						// pos是pointValue类型并返回CGPoint，其中有x,y
						let ponit = pos.cgPointValue
						posinfo.push([Number(ponit.x), Number(ponit.y)] as number[])
					}
					listpos.push(posinfo)
					bounedlist.push(iminfo)
					rulstText.push(rawValue == null ? '' : (rawValue!))

				}
				let res = {
					url: '',
					position: listpos,
					bounds: bounedlist,
					text: rulstText
				} as SCANNING_PHOTO_RESULT

				this.callback(res)
			})

		}
	}

	//映射坐标.
	function getCorrectionMatrix(c_w : number, c_h : number, image_w : number, image_h : number, image_point_x : number, image_point_y : number) : CGPoint {
		let sourcePoints = [
			0,
			0,
			image_w.toInt(),
			0,
			image_w.toInt(),
			image_h.toInt(),
			0,
			image_h.toInt()
		]
		let destinationPoints = [
			0,
			0,
			c_w.toInt(),
			0,
			c_w.toInt(),
			c_h.toInt(),
			0,
			c_h.toInt()
		]

		let vertexSize = 2
		let rotationDegrees = 90 // 默认后置摄像头就是90度的
		let shiftOffset = rotationDegrees / 90 * vertexSize;
		let tempArray = destinationPoints.slice(0)
		for (let i = 0; i < sourcePoints.length; i++) {
			let fromIndex = (i + shiftOffset) % sourcePoints.length
			destinationPoints[i] = tempArray[fromIndex.toInt()]
		}

		function scaleAndCenterContent(
			container : contaiaSize,
			content : contaiaSize
		) : contaiaCalseSize {
			// 计算缩放比例
			const scaleWidth = container.width / content.width;
			const scaleHeight = container.height / content.height;
			const scale = Math.min(scaleWidth, scaleHeight);

			// 计算居中偏移量
			const offsetX = (container.width - content.width * scale) / 2;
			const offsetY = (container.height - content.height * scale) / 2;

			return { scale, offsetX, offsetY } as contaiaCalseSize;
		}
		function mapContentCoordinatesToContainer(
			contentX : number,
			contentY : number,
			calcsize : contaiaCalseSize
		) : contaiPointXy {
			// 映射内容层坐标到容器层坐标
			const containerX = contentX * calcsize.scale + calcsize.offsetX;
			const containerY = contentY * calcsize.scale + calcsize.offsetY;

			return { x: containerX, y: containerY } as contaiPointXy;
		}

		let rc = scaleAndCenterContent(
			{ width: c_w, height: c_h } as contaiaSize,
			{ width: image_h, height: image_w } as contaiaSize
		)
		let result = mapContentCoordinatesToContainer(image_point_y, image_point_x, rc)

		let cp = new CGPoint(x = (c_w - result.x).toInt(), y = result.y.toInt());
		return cp;
	}
	function calcPoint(c_w : number, c_h : number, image_w : number, image_h : number, image_point_x : number, image_point_y : number) {
		// 图片被顺时旋转了90度
		let newconverxy = getCorrectionMatrix(c_w, c_h, image_w, image_h, image_point_x, image_point_y)
		return {
			x: newconverxy.x, y: newconverxy.y, minx: 0, maxx: 0, miny: 0, maxy: 0
		} as ConverXy

	}
</script>