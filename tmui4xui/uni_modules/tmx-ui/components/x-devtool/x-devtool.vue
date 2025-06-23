<script lang="ts">
	import { type PropType } from "vue"
	import { getDefaultColor } from "../../core/util/xCoreColorUtil.uts"
	import { checkIsCssUnit,getUid } from "../../core/util/xCoreUtil.uts"
	import { xRequestCall } from "../../core/util/config.uts"
	import { xConfig } from "../../config/xConfig.uts"
	import { xTableColumns,xRequestHistoryType } from "../..//interface.uts"
	
	/**
	 * @name 开发组件 xDevtool
	 * @page /pages/index/xrequest
	 * @category 展示组件
	 * @description 需要配合xRequest库，并打开dev模式，才可记录和使用。开发者可以将此组件预埋在某个页面，通过后台请求是否打开 和显示开发模式。这样在app发布后，通过远程调试也可打开请求记录等一些实质的数据。
	 * @constant 平台兼容
	 *	| H5 | andriod | IOS | 小程序 | UTS | UNIAPP-X SDK | version |
		| --- | --- | --- | --- | --- | --- | --- |
		| ☑ | ☑️ | ☑️ | x | ☑️ | 4.14+ | 1.0.0 |
	 */
	export default {
		data() {
			return {
				columns: [
					{
						title: '接口',
						key: 'api',
						width: "30%"
					} as xTableColumns,
					{
						title: '状态',
						key: 'status',
						width: "20%"
					} as xTableColumns,
					{
						title: '时间',
						key: 'time',
						width: "30%",
						desc: true
					} as xTableColumns,
					{
						title: '结果',
						key: 'result',
						width: '100%'
					} as xTableColumns
				] as xTableColumns[],
				
			}
		},
		computed: {
			hostUrl() : string {
				return xRequestCall.hostUrl
			},
			list():UTSJSONObject[]{
				let ls = xRequestCall.history.map((el:xRequestHistoryType):UTSJSONObject=>{
					return {
						api:el.api,
						status:el.status,
						time:el.time,
						result:el.result
					} as UTSJSONObject
				})
				
				return ls
			},
			_headBgColor():string{
				return xConfig.dark=='dark'?'#333':'#eee'
			}
		}
	}
</script>
<template>
	<x-float-drawer size="20%" :only-header="true" :disabledScroll="true">
		<template v-slot:default="{show,height}">
			<view class="xDevHeader" :style="{backgroundColor:_headBgColor}">
				<x-text  font-size="12" class="xDevHeaderLeft">请求域名</x-text>
				<view class="xDevHeaderRightWrap">
					<x-text font-size="12" class="xDevHeaderRight">{{hostUrl}}</x-text>
				</view>
			</view>
			<x-divider></x-divider>
			<view style="flex:1">
				<x-table :columns="columns" cell-height="100rpx" :list="list" height="100%" max-height="800rpx"></x-table>
			</view>
		</template>
	</x-float-drawer>
</template>
<style scoped>
	.xDevHeader {
		padding: 12px 12px;
		display: flex;
		flex-direction: row;
		justify-content: space-between;
	}
	.xDevHeaderRightWrap{
		flex:1;
		margin-left: 16px;
	}

	.xDevHeaderLeft {
		font-size: 12px;
	}

	.xDevHeaderRight {
		font-size: 12px;
	}
</style>