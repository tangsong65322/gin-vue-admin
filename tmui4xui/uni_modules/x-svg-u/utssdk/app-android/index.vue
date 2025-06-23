<template>
	<view>
	</view>
</template>

<script lang="uts">
	import TextUtils from 'android.text.TextUtils';
	import Button from 'android.widget.Button';
	import View from 'android.view.View';
	import SVG from "com.caverock.androidsvg.SVG"
	import ImageView from "android.widget.ImageView"
	import Context from "android.content.Context";
	import Xml from 'android.util.Xml';
	import XmlPullParser from 'org.xmlpull.v1.XmlPullParser';
	import PictureDrawable from 'android.graphics.drawable.PictureDrawable';
	import InputStream from 'java.io.InputStream';
	import File from 'java.io.File';
	import FileInputStream from 'java.io.FileInputStream';
	import ViewGroup from 'android.view.ViewGroup';
	export default {
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
		data() {
			return {}
		},
		/**
		 * 属性变化监听器实现
		 */
		watch: {
			"src": {
				handler(newValue : string, oldValue : string) {
					if(newValue=='') return;
					
					this.setImage(newValue)
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
			setImage(newval:string){
				let furl = UTSAndroid.convert2AbsFullPath(newval)
				let inputStream:InputStream|null = null;
				let context = UTSAndroid.getAppContext()! as Context;
				if(furl.indexOf('android_asset')==-1){
					inputStream = new FileInputStream(new File(furl))
				}else{
					inputStream = UTSAndroid.getUniActivity()!.getAssets().open(furl.replace("/android_asset/", ""));
				}
				if(inputStream ==null) return
				let svg = SVG.getFromInputStream(inputStream!);
				let pictureDrawable = new PictureDrawable(svg.renderToPicture());
				this.$el?.setImageDrawable(pictureDrawable);
				
			}
		},

		created() {

		},

		NVBeforeLoad() {

		},

		NVLoad() : ImageView {
			let imageview = new ImageView(UTSAndroid.getAppContext()! as Context);
			
			return imageview;
		},
		/**
		 * [可选实现] 原生View已创建
		 */
		NVLoaded() {

		},
		/**
		 * [可选实现] 原生View布局完成
		 */
		NVLayouted() {

		},
		/**
		 * [可选实现] 原生View将释放
		 */
		NVBeforeUnload() {

		},
		/**
		 * [可选实现] 原生View已释放，这里可以做释放View之后的操作
		 */
		NVUnloaded() {

		},
		/**
		 * [可选实现] 组件销毁
		 */
		unmounted() {

		},
		/**
		 * [可选实现] 自定组件布局尺寸，用于告诉排版系统，组件自身需要的宽高
		 * 一般情况下，组件的宽高应该是由终端系统的排版引擎决定，组件开发者不需要实现此函数
		 * 但是部分场景下，组件开发者需要自己维护宽高，则需要开发者重写此函数
		 */
		NVMeasure(size : UTSSize) : UTSSize {
			size.width = this.width.toFloat()
			size.height = this.height.toFloat()
			return size;
		}
	}
</script>

<style>

</style>