<template>
	<view class="boxView">
		
		
	</view>
</template>
<script lang="uts">
	import Context from 'android.content.Context'
	import LinearLayout from 'android.widget.LinearLayout';
	import FrameLayout from 'android.widget.FrameLayout';
	import ViewGroup from 'android.view.ViewGroup';
	import View from 'android.view.View';
	import ImageView from "android.widget.ImageView"
	import InputStream from 'java.io.InputStream'
	import Uri from 'android.net.Uri';
	import File from 'java.io.File'
	import BufferedImage from 'java.awt.image.BufferedImage'
	import IOException from 'java.io.IOException'
	import NotFoundException from 'com.google.zxing.NotFoundException'
	import FormatException from 'com.google.zxing.FormatException'
	import ChecksumException from 'com.google.zxing.ChecksumException'
	
	import BarcodeScanner from "com.google.mlkit.vision.barcode.BarcodeScanner"
	import BarcodeScannerOptions from "com.google.mlkit.vision.barcode.BarcodeScannerOptions"
	import BarcodeScanning from "com.google.mlkit.vision.barcode.BarcodeScanning"
	import ZoomSuggestionOptions from "com.google.mlkit.vision.barcode.ZoomSuggestionOptions"
	import ZoomCallback from "com.google.mlkit.vision.barcode.ZoomSuggestionOptions.ZoomCallback"
	import Barcode from "com.google.mlkit.vision.barcode.common.Barcode"
	import InputImage from "com.google.mlkit.vision.common.InputImage"
	
	import Task from "com.google.android.gms.tasks.Task"
	import List from "java.util.List"
	import ByteBuffer from 'java.nio.ByteBuffer'
	import ImageFormat from 'android.graphics.ImageFormat'
	

	import Bitmap from "android.graphics.Bitmap"
	import BitmapFactory from "android.graphics.BitmapFactory"
	
	import Color from "android.graphics.Color"
	import BarcodeFormat from "com.google.zxing.BarcodeFormat"
	import EncodeHintType from "com.google.zxing.EncodeHintType"
	import MultiFormatWriter from "com.google.zxing.MultiFormatWriter"
	import MultiFormatReader from "com.google.zxing.MultiFormatReader"
	import RGBLuminanceSource from "com.google.zxing.RGBLuminanceSource"
	
	
	import BinaryBitmap from "com.google.zxing.BinaryBitmap"
	import HybridBinarizer from "com.google.zxing.common.HybridBinarizer"
	import WriterException from "com.google.zxing.WriterException"
	import BitMatrix from "com.google.zxing.common.BitMatrix"
	import BufferedImageLuminanceSource from "com.google.zxing.client.j2se.BufferedImageLuminanceSource"

	import ByteArrayOutputStream from 'java.io.ByteArrayOutputStream'
	import Base64 from 'java.util.Base64'
	
	import Context from 'android.content.Context'
	import SurfaceView from 'android.view.SurfaceView'
	import { chooseImage } from "./index.uts"
	import { xCamera } from "./camera.uts"
	import { SCANNING_OPTIONS,CAMERA_PHOTO_SIZE,BARCODEFORMAT,CallFunType,SCANNING_PHOTO_RESULT_BOUND ,SCANNING_PHOTO_RESULT} from "../interface.uts"
	

	export default {
		name: "x-mlkit-scannig-u",
		data() {
			return {
				CBOX: null as null | FrameLayout,
				xcamera:null as null|xCamera,
				defaultscaneventFun:null as CallFunType|null
			}
		},
		emits:[
			/**
			 * 多个码的时候点击触发，返回码内容
			 * @param {string} str - 点的码
			 */
			'clickQr',
			/**
			 * 识别成功触发
			 * @param {string[]} str[] - 识别的码结果集
			 */
			'scan'
			],
		props:{
			
			/**
			 * 相机预览像素宽，请最好为正方形
			 */
			cameraWidth:{
				type:Number,
				default:800
			},
			/**
			 * 相机预览像高，请最好为正方形
			 */
			cameraeiHght:{
				type:Number,
				default:800
			},
			/**
			 * 是否自动打开相机
			 */
			autoOpenCamera:{
				type:Boolean,
				default:true
			},
			/**
			 * 是否开启闪光灯
			 */
			flash:{
				type:Boolean,
				default:false
			}
	
		},
		NVLoad() : FrameLayout {
			let grop = new FrameLayout(UTSAndroid!.getAppContext()!)
			this.CBOX = grop;
			return grop
		},
		NVLayouted() {
			if(this.autoOpenCamera){
				this.createXcamrera();
			}
		},
		NVBeforeUnload(){
			this.xcamera?.closeCamera()
		},
		methods: {
			/**
			 * 检查相机权限
			 */
			checkPermissions() : Promise<boolean> {
				let permissionCheck = ["android.permission.CAMERA"]
				let _this = this;
				// 请求拍照权限
				return new Promise(res => {
					if (UTSAndroid.checkSystemPermissionGranted(UTSAndroid.getUniActivity()!, permissionCheck)) {
						// _this.cameraPermissioPass = true
						res(true)
					} else {
						console.log("当前不具备指定权限")
						// 请求拍照权限
						UTSAndroid.requestSystemPermission(UTSAndroid.getUniActivity()!, permissionCheck, function (allRight : boolean, _ : string[]) {
							// _this.cameraPermissioPass = allRight
							res(true)
						}, function (_ : boolean, _ : string[]) {
							//用户拒绝了部分权限
							// _this.cameraPermissioPass = false
							res(false)
						})
					}
				})
			},
		
			/** 私有函数，外部不要调用。 */
			createXcamrera(){
				let _this = this;
				this.xcamera = new xCamera(this.CBOX!,{
					width:this.cameraWidth,height:this.cameraeiHght,cameraDevice:'BACK',
					zoom:5,
					flashMode:this.flash
				} as SCANNING_OPTIONS)
				
				this.xcamera!.setCallEvent((str:string[],type:'auto'|'click')=>{
					if(type=='auto'){
						_this.$emit('scan',str)
					}else if(type=='click'){
						_this.$emit('clickQr',str[0]!)
					}
				})
				this.xcamera!.openCamera()
				
			},
			/** 手动开启和关闭闪光灯 */
			setFlashModel(flash:boolean){
				if(this.xcamera != null){
					this.xcamera!.setFlashModel(flash)
				}
			},
			/** 手动打开相机预览 */
			openCamera(){
				let _this = this;
				let isPrivacyAgreeCamrea = uni.getStorageSync('isPrivacyAgreeCamreaByTmui')
				if(isPrivacyAgreeCamrea!='on'){
					uni.showModal({
						title:"提醒",
						content:"将授权你的设备相机使用权限进行拍摄识别功能，是否允许？",
						success(isPermisseions){
							if(isPermisseions.confirm){
								_this.checkPermissions()
								.then((res:boolean)=>{
									_this.createXcamrera()
									uni.setStorageSync('isPrivacyAgreeCamreaByTmui','on')
								})
								.catch(()=>{
									uni.setStorageSync('isPrivacyAgreeCamreaByTmui','off')
								})
							}
						},
						fail(){
							uni.showToast({title:"未授权相机使用权",icon:"none"})
						}
					})
				}else{
					_this.createXcamrera()
				}
			},
			/** 关闭相机 */
			closeCamera(){
				this.xcamera?.closeCamera()
			},
			chooseImage(){
				let _this = this;
				uni.chooseImage({
					count: 1,
					albumMode:"system",
					sourceType:['album'],
					success(evt : ChooseImageSuccess) {
						
						if (evt.tempFilePaths.length > 0) {
						
							const imgs = evt.tempFilePaths[0] as string;
							try {
								const decodedPath = Uri.decode(imgs).substring(7)
								const file = File(decodedPath)
								let image = InputImage.fromFilePath(UTSAndroid.getAppContext() as Context, Uri.fromFile(file));
								let scanner = BarcodeScanning.getClient();
								scanner.process(image)
									.addOnSuccessListener((barcodes) => {
										let listpos = [] as number[][][]
										let bounedlist = [] as SCANNING_PHOTO_RESULT_BOUND[]
										let rulstText = [] as string[]
										for (barcode in barcodes) {
											// 位置信息
											let bounds = barcode.boundingBox
											// 坐标
											let corners = barcode.cornerPoints
											// 解析的内容
											let rawValue = barcode.rawValue
											// 码的格式
											let valueType = barcode.valueType
								
											if (rawValue != null && bounds != null && corners != null) {
												let iminfo = { width: bounds!.width(), height: bounds!.height(), centerX: bounds!.centerX(), centerY: bounds!.centerY() } as SCANNING_PHOTO_RESULT_BOUND
												let posinfo = [] as number[][]
												for (pos in corners) {
													posinfo.push([pos!.x as number, pos!.y as number] as number[])
												}
												listpos.push(posinfo)
												bounedlist.push(iminfo)
												rulstText.push(rawValue)
											}
										}
										// res({
										// 	url: imgs,
										// 	position: listpos,
										// 	bounds: bounedlist,
										// 	text: rulstText
										// } as SCANNING_PHOTO_RESULT)
										// let resultstr = uni.getStorageSync("xMlKITScaning")
										_this.$emit('scan',rulstText.length==0?[]:rulstText)
									})
								
							} catch (e : IOException) {
								_this.$emit('scan',[] as string[])
							}
						}
					},
					fail() {
						_this.$emit('scan',[] as string[])
					}
				})
			}
			

		}
	}
</script>