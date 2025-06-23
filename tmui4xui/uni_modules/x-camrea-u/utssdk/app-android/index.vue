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
	import SurfaceView from 'android.view.SurfaceView'
	
	import { AUTH_CALL_BACK_TYPE } from "../interface.uts"
	import { xCamera } from "./camera.uts"



	export default {
		name: "x-camrea-u",
		data() {
			return {
				CBOX: null as null | FrameLayout,
				xcamera: null as null | xCamera,
				defaultscaneventFun: null 
			}
		},
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
		props: {

			/**
			 * 相机预览像素宽，请最好为正方形
			 */
			cameraWidth: {
				type: Number,
				default: 800
			},
			/**
			 * 相机预览像高，请最好为正方形
			 */
			cameraeiHght: {
				type: Number,
				default: 800
			},
			/**
			 * 是否自动打开相机
			 */
			autoOpenCamera: {
				type: Boolean,
				default: true
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
		NVLoad() : FrameLayout {
			let grop = new FrameLayout(UTSAndroid!.getAppContext()!)
			this.CBOX = grop;
			return grop
		},
		NVLayouted() {
			this.xcamera = new xCamera(this.CBOX!)
			let t =  this;
			if(this.autoOpenCamera){
				this.open();
			}
			UTSAndroid.onAppActivityPause(()=>{
				t.pauseResum()
			});
		},
		NVBeforeUnload() {
			let t =  this;
			UTSAndroid.offAppActivityPause(()=>{
				t.pauseResum()
			});
		},
		NVUnloaded(){
			this.close()
		},
		methods: {
			pauseResum(){
				if(this.xcamera?.isOpeningCameraing==true){
					this.open()
				}
			},
			/**
			 * 检查相机权限
			 */
			checkPermissions(call:(istrue:boolean)=>void) {
				let permissionCheck = ["android.permission.CAMERA"]
				let _this = this;
				if (UTSAndroid.checkSystemPermissionGranted(UTSAndroid.getUniActivity()!, permissionCheck)) {
					// _this.cameraPermissioPass = true
					call(true)
				} else {
					console.log("当前不具备指定权限")
					// 请求拍照权限
					UTSAndroid.requestSystemPermission(UTSAndroid.getUniActivity()!, permissionCheck, function (allRight : boolean, _ : string[]) {
						// _this.cameraPermissioPass = allRight
						call(true)
					}, function (_ : boolean, _ : string[]) {
						//用户拒绝了部分权限
						// _this.cameraPermissioPass = false
						call(false)
					})
				}
			},

			
			/** 手动打开相机预览 */
			open() {
				let _this = this;
				this.checkPermissions((auth:boolean)=>{
					if(auth){
						_this.xcamera?.setCameraDir(this.orientation)
						_this.xcamera?.setFlash(this.flash)
						_this.xcamera?.openCamera()
					}
				})
			},
			take() {
				let t = this;
				this.xcamera?.takPhoto((path:string)=>{
					let map = new Map<string,string>()
					map.set('path',path+'')
					t.$emit('take',map)
				})
			},
			start() {
				let t = this;
				this.xcamera?.startRecoderVideo((path:string)=>{
					let map = new Map<string,string>()
					map.set('path',path+'')
					t.$emit('recoder',map)
				})
			},
			/**
			 * 暂停录制
			 */
			pause(){
				this.xcamera?.pauseRecoderVideo()
			},
			/**
			 * 停止录制,不是关闭相机,如果不想继续录制可以执行关闭相机.
			 */
			stop(){
				this.xcamera?.stopRecoderVideo()
			},
			
			/** 关闭相机 */
			close() {
				this.xcamera?.closeCamera()
			}


		}
	}
</script>