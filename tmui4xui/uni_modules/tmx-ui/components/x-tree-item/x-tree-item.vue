<script lang="ts">
	import { type PropType } from "vue"
	import { getDefaultColor } from "../../core/util/xCoreColorUtil.uts"
	import { checkIsCssUnit, getUid } from "../../core/util/xCoreUtil.uts"
	import { xConfig } from "../../config/xConfig.uts"
	import { flatChildrensId, setChildrenByid, findParentNode } from "../x-tree/util.uts"
	type callbackType = (id : string) => Promise<UTSJSONObject[]>
	
	/**
	 * @name 树子节点 xTreeItem
	 * @description xTree内部子组件，不可引用。
	 * @page /pages/index/tree
	 * @category 表单组件
	 * @constant 平台兼容
	 *	| H5 | andriod | IOS | 小程序 | UTS | UNIAPP-X SDK | version |
		| --- | --- | --- | --- | --- | --- | --- |
		| ☑ | ☑️ | ☑️ | ☑️ | ☑️ | 4.44+ | 1.1.9 |
	 */
	export default {
		data() {
			return {
				nowIds: [] as string[],
				showChildren: true,
				openFLoderIds: [] as string[],
				tid: 0,
				_list: [] as UTSJSONObject[],
				nowediteItem:null as null|UTSJSONObject,
				showModal:false,
				nowediteItemText:"",
				nowediteItemId:"",
				editeType:"change",//change/add,
				newItem:null as null|UTSJSONObject
			}
		},
		emits: [
			/**
			 * 选中切换时触发
			 * @@param {string[]} ids - 打开的id数组 
			 */
			'change',
			/**
			 * 节点标签被点击
			 * @@param {UTSJSONObject} item - 打开的id数组 
			 */
			'childrenClick',
			/**
			 * 父节点展开和关闭
			 * @@param {string[]} ids - 打开的id数组 
			 */
			'openFolderChange',
			'setChildrenData',
			'update:modelValue'
		],
		props: {
			idList: {
				type: Array as PropType<string[]>,
				default: () : string[] => [] as string[]
			},
			list: {
				type: Array as PropType<UTSJSONObject[]>,
				default: () : UTSJSONObject[] => [] as UTSJSONObject[]
			},
			idKey: {
				type: String,
				default: "id"
			},
			labelKey: {
				type: String,
				default: "text"
			},
			folderId: {
				type: Array as PropType<string[]>,
				default: () : string[] => [] as string[]
			},
			/**
			 * 选中时的高亮颜色或者主题
			 */
			color: {
				type: String,
				default: ""
			},
			/**
			 * 用户交互时是否禁用选中交互
			 * 但不影响你赋值选中
			 */
			disabledParentBox: {
				type: Boolean,
				default: false
			},
			/**
			 * 是否允许选中父级的时候把它的所有子级也选上。
			 */
			parentSelectedFullChildren: {
				type: Boolean,
				default: false
			},
			/**
			 * 是否停用选中功能，只能是已读状态了
			 * 但不影响你赋值选中
			 */
			disabled: {
				type: Boolean,
				default: false
			},
			beforeOpenFloder: {
				type: Function as PropType<callbackType>,
				default: (itemId : string) : Promise<UTSJSONObject[]> => {
					return Promise.resolve([] as UTSJSONObject[])
				}
			},
			/**
			 * 关闭和打开时图标/图片地址
			 * 必须为长度2,第一项关闭时图标,第2项关闭时图标
			 */
			floaderIcon:{
				type:Array as PropType<string[]>,
				default:():string[] => ['folder-add-line','folder-open-fill'] as string[]
			},
			/**
			 * 是否显示默认前置开和关的图标
			 */
			showFloaderIcon:{
				type:Boolean,
				default:true
			},
			/**
			 * 是否显示选中的box图标
			 */
			showChecked:{
				type:Boolean,
				default:false
			},
			/**
			 * 选中与未选中时的图标/图片地址
			 * 必须为长度2,第一项未选中,第二项选中时图标
			 */
			checkedIcon:{
				type:Array as PropType<string[]>,
				default:():string[] => ['checkbox-blank-line','checkbox-fill'] as string[]
			},
		},
		computed: {
		
			_checkedIcon() :  string[] {
				return this.checkedIcon
			},
			_showChecked() : boolean {
				return this.showChecked
			},
			_showFloaderIcon() : boolean {
				return this.showFloaderIcon
			},
			_floaderIcon() : string[] {
				return this.floaderIcon;
			},
			_childrenList() : UTSJSONObject[] {
				return this.list;
			},
			_folderId() : string[] {
				return this.openFLoderIds
			},
			_color() : string {
				return this.color
			},
			_disabledParentBox() : boolean {
				return this.disabledParentBox
			},
			_disabled() : boolean {
				return this.disabled
			},
			_parentSelectedFullChildren() : boolean {
				return this.parentSelectedFullChildren
			},
			_fontSize() : string {

				if (xConfig.fontScale == 1) return '16';
				return (16 * xConfig.fontScale).toString()
			},
			_itemColor() : string {
				if (xConfig.dark == 'dark') return 'white'
				return '#666';
			}
		},
		watch: {
			folderId(newVal : string[]) {

				if (newVal.join("") == this.openFLoderIds.join("")) return;

				this.openFLoderIds = newVal
			},
			list() {
				// this.$forceUpdate()
				this._list = this.list;
			},
			idList(newVal : string[]) {
				if (newVal.join("") == this.nowIds.join("")) return;
				this.nowIds = newVal;
			}
		},
		mounted() {
			this._list = this.list;
			this.openFLoderIds = this.folderId
			this.nowIds = this.idList;
		},
		methods: {
			async childrenEvent(item : UTSJSONObject) : Promise<any> {
				let id = item.getString(this.idKey)
				if (id == null) {
					return Promise.resolve(true);
				}

				this.$emit("childrenClick", item)

				let idsIndex = -1;
				for (let i = 0; i < this.openFLoderIds.length; i++) {
					if (this.openFLoderIds[i] == id) {
						idsIndex = i;
						break;
					}
				}

				// 先判断 是不是父级，就是有没有children要展开。有就展开或者 关闭。没有不操作。
				let children = this.getChildren(item)
				let isOpenChildren = item.getArray('children')
				// 只有有children字段的才可以异步打开继续加载数据。
				if (isOpenChildren == null) {
					return Promise.resolve(true);
				}

				if (idsIndex == -1 && children.length == 0) {

					// 没有子级再判断有没有异步加载的数据。
					let asyncList = await this.beforeOpenFloder(id)
					let resultList = asyncList as UTSJSONObject[]
					if (resultList.length > 0) {
						let n = setChildrenByid(this._list, id, this.idKey, resultList)
						item.set('children', resultList)
						children = resultList

						this.$emit('setChildrenData', id, this._list)
					}
				}

				if (children.length == 0) {
					// 没有子级触发title事件就行

					return Promise.resolve(true);
				}


				if (idsIndex > -1) {
					this.openFLoderIds.splice(idsIndex, 1)
				} else {
					this.openFLoderIds.push(id)
				}

				this.$emit('openFolderChange', this.openFLoderIds.slice(0), idsIndex == -1 ? 'open' : 'close', id)

				return Promise.resolve(true);
			},
			setChildrenDataEnd(id : string, item : UTSJSONObject[]) {
				let parent = findParentNode(this._list, id, this.idKey) as UTSJSONObject | null

				if (parent == null) {
					let index = this._list.findIndex((item) : boolean => id == item.getString(this.idKey)!)
					if (index > -1) {
						this._list[index].set('children', item)
						this.$emit('setChildrenData', id, this._list)
					}
				} else {
					let index = this._list.findIndex((item) : boolean => item!.getString(this.idKey) != parent!.getString(this.idKey)!)
					if (index > -1) {
						this._list[index].set('children', item)
						this.$emit('setChildrenData', id, this._list)
					}
				}


			},
			isInOpenFloder(item : UTSJSONObject) : boolean {
				let id = item.getString(this.idKey)
				if (id == null) {
					return false;
				}
				if (this.openFLoderIds.includes(id)) return true;
				return false
			},
			getListItemHeight(item : UTSJSONObject) : number {
				let id = item.getString(this.idKey)
				if (id == null || !this.isInOpenFloder(item)) {
					return 1;
				}
				let children = this.getChildren(item)
				if (children.length == 0) return 1;
				return children.length + 1
			},
			getChildren(item : UTSJSONObject) : UTSJSONObject[] {
				let c = item.getArray<UTSJSONObject>('children')
				if (c == null) return [] as UTSJSONObject[]
				return c;
			},
			updateIds() {
				// this.$emit()
			},

			openFolderChangeEnd(ids : string[], type : string, id : string) {
				// let fullIds = new Set(this.openFLoderIds.concat(ids))
				// let idsreal = [] as string[]
				// fullIds.forEach((val : string) => {
				// 	idsreal.push(val)
				// })
				// this.openFLoderIds = ids
				this.$emit('openFolderChange', ids.slice(0), type, id)
			},
			childrenClickEnd(item : UTSJSONObject) {
				this.$emit("childrenClick", item)
			},
			checkBoxClickEvent(item : UTSJSONObject) {

				if (this.isDisabled(item)) {
					return;
				}

				let id = item.getString(this.idKey)
				if (id == null) {
					return;
				}
				let idsIndex = -1;
				for (let i = 0; i < this.nowIds.length; i++) {
					if (this.nowIds[i] == id) {
						idsIndex = i;
						break;
					}
				}
				let sids = this.nowIds.slice(0)
				
				let indeterminate = this.isIndeterminate(item)
				let selected = this.isSelected(item)
				
				if(idsIndex>-1){
					sids.splice(idsIndex, 1)
					if (this._parentSelectedFullChildren && this.getChildren(item).length > 0) {
						let tmepids = flatChildrensId(item, this.idKey)
						sids = sids.filter((el) : boolean => !tmepids.includes(el))
					}
					
				//如果不存在选中中,它可能是半选状态或者完全没有选中.
				}else{
					sids.push(id)
					// 如果允许单选父,不影响子,需要单独处理,其它交给父组件处理
					if (this._parentSelectedFullChildren && this.getChildren(item).length > 0) {
						let tmepids = flatChildrensId(item, this.idKey)
						// tmepids = tmepids.filter((yid:string):string => !this.nowIds.includes(yid))
						sids = sids.concat(tmepids)
					}
				}
				
				
				
				
				

				this.nowIds = sids;
				// 更新父节点状态
				// this.updateParentNodeStatus();
				this.$emit('change', this.nowIds.slice(0))
			},
			changeEnd(ids : string[]) {
				// 当子节点状态变化时，更新当前节点状态
				this.nowIds = ids.slice(0);
				this.$emit('change', ids.slice(0))
			},
			
			
			isSelected(item : UTSJSONObject) : boolean {
				let id = item.getString(this.idKey)
				id = id == null ? "" : id;
				return this.nowIds.includes(id)
			},
			// 检查节点是否处于半选状态（部分子节点被选中）
			isIndeterminate(item : UTSJSONObject) : boolean {
				// 如果节点已被选中，则不是半选状态
				if (this.isSelected(item)) return false;
				
				// 获取所有子节点ID
				let children = this.getChildren(item);
				if (children.length === 0) return false;
				
				// 获取所有可选的子节点ID
				let allChildrenIds = flatChildrensId(item, this.idKey);
				if (allChildrenIds.length === 0) return false;
				
				// 检查是否有部分子节点被选中
				let selectedChildrenCount = 0;
				for (let i = 0; i < allChildrenIds.length; i++) {
					if (this.nowIds.includes(allChildrenIds[i])) {
						selectedChildrenCount++;
						
					}
				}
				
				// 如果有部分子节点被选中（不是全部也不是零个），则是半选状态
				return selectedChildrenCount > 0 && selectedChildrenCount < allChildrenIds.length;
			},
			// 是否被禁用选择
			isDisabled(item : UTSJSONObject) : boolean {
				let children = this.getChildren(item)
				// 自己的单独的禁用状态
				let disabled = item.getBoolean("disabled")
				disabled = disabled == null ? false : disabled
				// 父级
				if (children.length > 0) {
					return this._disabledParentBox || disabled || this._disabled
				}
				return disabled || this._disabled
			},
			editeclick(){
				if(this.nowediteItem==null) return;
				if(this.nowediteItemText==''){
					uni.showToast({title:"标题不能为空",icon:'none'})
					return;
				}
				let item = this.nowediteItem!
				let id = item.getString(this.idKey)!
				
				if(this.editeType=='change'){
					item.set(this.labelKey,this.nowediteItemText)
					item.set(this.idKey,this.nowediteItemId)
					let index = this._list.findIndex((item) : boolean => id == item.getString(this.idKey)!)
					if (index > -1) {
						this._list[index] = item
						this.$emit('setChildrenData', id, this._list)
					}
				}else if(this.editeType == 'add'&&this.newItem!=null){
					id = this.nowediteItemId
					if(id==''){
						id = Math.random().toString(16).substring(1,20)
					}
					this.newItem!.set(this.labelKey,this.nowediteItemText)
					this.newItem!.set(this.idKey,id)
					
					let nextChildre = this.getChildren(item)
					if(nextChildre.length==0){
						this.newItem!.set('children',[this.newItem!] as UTSJSONObject[])
					}else{
						nextChildre.push(this.newItem! as UTSJSONObject)
					}
					let index = this._list.findIndex((item) : boolean => id == item.getString(this.idKey)!)
					if (index > -1) {
						this._list[index] = item
						this.$emit('setChildrenData', id, this._list)
					}
					
					this.nowediteItemId = ''
					this.nowediteItemText = ''
				}
				
				
			},
			isShowEdite(item:UTSJSONObject):Boolean{
				let showEditeLabel = item.getBoolean('showEdite')
				return showEditeLabel == true;
			},
			isShowAdd(item:UTSJSONObject):Boolean{
				let showEditeLabel = item.getBoolean('showAdd')
				return showEditeLabel == true;
			},
			
			isShowRemove(item:UTSJSONObject):Boolean{
				let showEditeLabel = item.getBoolean('showRemove')
				return showEditeLabel == true;
			},
			showModalEdte(item:UTSJSONObject,editeType:string){
				if(editeType == 'add'){
					let newitem = {
						disabled:false,
						showEdite:false,
						showRemove:true
					} as UTSJSONObject
					newitem.set(this.labelKey,"")
					newitem.set(this.idKey,"")
					this.newItem = newitem
				}
				let disabled = this.isDisabled(item)
				this.editeType = editeType;
				if(disabled) return;
				this.nowediteItem = item;
				if(editeType == 'change'){
					this.nowediteItemText = item.getString(this.labelKey)==null?'':item.getString(this.labelKey)!
					this.nowediteItemId = item.getString(this.idKey)==null?'':item.getString(this.idKey)!
				}else if(editeType == 'add'){
					this.nowediteItemId = ''
					this.nowediteItemText = ''
				}
				this.showModal = true;
			},
			removeItem(item:UTSJSONObject){
				console.log(this._list)
				let t = this;
				uni.showModal({
					title:"提醒",
					content:"确认删除?",
					success(res){
						if(res.confirm){
							
							let id = item.getString(t.idKey)!
							let index = t._list.findIndex((item:UTSJSONObject) : boolean => id == item.getString(t.idKey)!)
							if (index > -1) {
								t._list.splice(index,1)
								t.$emit('setChildrenData', id, t._list)
							}
						}
					}
				})
				
			}
		}
	}
</script>
<template>
	<view class="xTree">
		<x-modal height="auto" @confirm="editeclick" :title="editeType=='add'?'添加下级':'修改内容'" v-model:show="showModal">
			<view v-if="nowediteItem!=null">
				<x-input dark-bg-color="" height="48" v-model="nowediteItemText">
					<template v-slot:inputLeft>
						<x-text _style="padding:0 12px">标题值</x-text>
					</template>
				</x-input>
				<view style="height:10px"></view>
				<x-input dark-bg-color="" height="48" placeholder="不要重复,空时自动生成" v-model="nowediteItemId">
					<template v-slot:inputLeft>
						<x-text _style="padding:0 12px">标识ID</x-text>
					</template>
				</x-input>
			</view>
		</x-modal>
		<view class="xTreeItemCell" v-for="(item,index) in _list" :key="index">
			<view 
			:hover-start-time="5" :hover-stay-time="30" :hover-class="getChildren(item).length>0?'hoverClass':'hoverClassOff'"
			@click.stop="childrenEvent(item)" :style="{height:'50px'}" class="xTreeItemCellWrap">
				<view class="xTreeItemCellWrapLeft">
					<view v-if="item.getArray('children')!=null&&_showFloaderIcon" class="xTreeItemCellWrapLeftIcon">
						<x-icon color="#333333" v-if="!isInOpenFloder(item)" font-size="21"
							:name="_floaderIcon[0]"></x-icon>
						<x-icon :color="_color" v-if="isInOpenFloder(item)" font-size="21"
							:name="_floaderIcon[1]"></x-icon>

					</view>
					<text :style="{color:isSelected(item)?_color:_itemColor,fontSize:_fontSize}"
						class="xTreeItemCellWrapLeftText">{{item.getString(labelKey)}}</text>
				</view>
				<view v-if="isShowAdd(item)" :hover-start-time="5" :hover-stay-time="30" hover-class="hoverClass"
					@click.stop="showModalEdte(item,'add')" style="margin-right:10px;" >
					<x-icon :color="!isDisabled(item)?_color:'#cecece'" font-size="21"
						name="add-large-line"></x-icon>
				</view>
				<view v-if="isShowEdite(item)" :hover-start-time="5" :hover-stay-time="30" hover-class="hoverClass"
					@click.stop="showModalEdte(item,'change')" style="margin-right:10px;" >
					<x-icon :color="!isDisabled(item)?_color:'#cecece'" font-size="21"
						name="edit-box-line"></x-icon>
				</view>
				<view v-if="isShowRemove(item)" :hover-start-time="5" :hover-stay-time="30" hover-class="hoverClass"
					@click.stop="removeItem(item)" style="margin-right:10px;" >
					<x-icon :color="!isDisabled(item)?_color:'#cecece'" font-size="21"
						name="delete-bin-2-line"></x-icon>
				</view>
				<view v-if="_showChecked" :hover-start-time="5" :hover-stay-time="30" hover-class="hoverClass"
					@click.stop="checkBoxClickEvent(item)" :style="{opacity:isDisabled(item)?'0.3':'1'}">
					<x-icon v-if="_parentSelectedFullChildren" :color="isSelected(item) || isIndeterminate(item) ? _color : '#cecece'" font-size="21"
						:name="isSelected(item) ? _checkedIcon[1] : (isIndeterminate(item) ? 'indeterminate-circle-line' : _checkedIcon[0])"></x-icon>
					<x-icon v-else :color="isSelected(item) ? _color : '#cecece'" font-size="21"
						:name="isSelected(item) ? _checkedIcon[1] : _checkedIcon[0]"></x-icon>
						
						
				</view>
			</view>
			<x-tree-item 
			:checkedIcon="checkedIcon"
			:showChecked="_showChecked"
			:showFloaderIcon="showFloaderIcon"
			:floaderIcon="floaderIcon"
			@childrenClick="childrenClickEnd" @openFolderChange="openFolderChangeEnd"
				@setChildrenData="setChildrenDataEnd" :beforeOpenFloder="beforeOpenFloder"
				:parentSelectedFullChildren="_parentSelectedFullChildren" :disabled="_disabled"
				:disabledParentBox="_disabledParentBox" @change="changeEnd" :idList="nowIds" :color="_color"
				:folderId="openFLoderIds" :idKey="idKey" :labelKey="labelKey" style="margin-left: 30px;"
				v-if="isInOpenFloder(item)&&showChildren" :list="getChildren(item)" v-model="nowIds"></x-tree-item>
		</view>

	</view>
</template>
<style scoped>
	.hoverClass {
		background-color: rgba(0, 0, 0, 0.03);
	}
	.hoverClassOff {
		background-color: transparent;
	}
	.xTreeItemCellWrapLeftText {
		flex: 1;
		text-overflow: ellipsis;
		lines: 2;
		/* #ifndef APP */
		display: -webkit-box;
		-webkit-box-orient: vertical;
		overflow: hidden;
		word-break: break-all;
		-webkit-line-clamp: 2;
		/* #endif */
	}

	.xTreeItemCellWrapLeftIcon {
		display: flex;
		flex-direction: row;
		justify-content: flex-start;
		align-items: center;
		width: 30px;
	}

	.xTreeItemCellWrapLeft {
		flex: 1;
		display: flex;
		flex-direction: row;
		justify-content: flex-start;
		align-items: center;
	}

	.xTreeItemCellWrap {
		display: flex;
		flex-direction: row;
		justify-content: space-between;
		align-items: center;
		border-bottom: 1px solid rgba(0, 0, 0, 0.03);

	}
</style>