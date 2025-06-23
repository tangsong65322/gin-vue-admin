<template>
	<view :id="id">
		<img style="width: 100%;height: 100%;object-fit: contain;" :src="_src"></img>
	</view>
</template>
<script lang="uts">

	let uuid = Date.now().toString()
	export default {
		data() {
			return {
				id: 'svg-'+uuid,
				_src:'',
				_width:16,
				_height:16,
				tiddDD:0
			}
		},
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
		NVLoad() : any {
			
			return null
		},
		NVLayouted() {
			
		},
		NVBeforeUnload() {
		},
		watch: {
			"src": {
				handler(newValue : String, oldValue : String) {
					this._src = newValue;
				},
				immediate: true
			},
			"width": {
				handler(newValue : Number, oldValue : Number) {
					this._width = newValue;
				},
				immediate: true
			},
			"height": {
				handler(newValue : Number, oldValue : Number) {
					this._height = newValue;
				},
				immediate: true
			},
		},
		methods: {
		
		}
	}
</script>