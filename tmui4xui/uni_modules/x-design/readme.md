# x-design
### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

这是标准组件库依赖系列

### 兼容性

| IOS | Andriod | WEB |
| --- | --- | --- |
| 支持9.0+ | 支持5.0+ | 不支持 |

### 使用

与正常的uvue组件一样使用,但不同的是,这些全是原生标准组件,需要打包或者mac系统配置环境使用,不能在普通win环境使用.
如果在win下使用,请先在页面调用 ,再打基座使用.如果是mac配置好环境可以直接使用.

**xd-blur有三个属性**
blur:0-100模糊度
bgColor:模糊的叠加颜色
into:模糊对象,可选值parent:模糊它的父级(即背景),self:模糊自身内容(标签内的所有内容被模糊)
当模糊背景的时候需要设置为fiexd在根节点的直接子直接,这样可以模糊动态背景内容,当模糊自身内容时,请把内容放到标签内.

### 模糊组件xdBlur
模糊背景:
它的背景会被局部模糊到xd-blur自身(俗称的磨砂背景效果),作为背景模糊时，插槽会失效，因此你要把它当作一个背景图定位到你的内容下方。
```vue
<scroll-view style="flex:1;">
<xd-blur style="position:fixed;left: 0;top: 0px;width: 100%;height: 100px;z-index: 10;"></xd-blur>
</scroll-view>
```
模糊自己的内容:
它的内容会被全部模糊化(俗称的图片模糊,内容模糊)
```vue
<xd-blur into="self">
	<x-sheet>
		<x-button  :block="true" class="mb-12">主色</x-button>
		<x-button :block="true" class="mb-12" color="error">错误</x-button>
		<x-button :block="true" class="mb-12" color="warn">警告</x-button>
		<x-button :block="true" class="mb-12" color="danger">危险</x-button>
		<x-button :block="true" class="mb-12" color="success">成功</x-button>
		<x-button darkColor="#222222" :block="true" :shadow="[0,0]" class="mb-12" color="info">次要</x-button>
	</x-sheet>
</xd-blur>
```
