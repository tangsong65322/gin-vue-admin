# x-screenshot-s
### 开发文档

1. 可以对窗口进行静默截图
2. 可以对某一个view节点进行截图

### 应用场景

1. 对产品端,给用户反馈保存时,可以对当前反馈的页面进行截图反馈,比如界面异常上传等
2. 对局部节点截图保存可以进行对局部的分享保存,比如页面的排版海报
3. 对整个页面分享保存

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | x | x |

### 注意事项

使用前一定要打基座才可用，一定要在页面上先引用，再去打基座。
如果你mac开发。ios可以不用打基座，能直接使用（但前提是你要配置好原生开发环境，否则一样要打包）
如果你是开始安卓，不管是mac,win电脑都要打包基座才能使用。

### API说明

#### getRootShotImage
```ts
function getRootShotImage(callback: (str: string) => void): void
```

**参数说明：**
- callback：截图完成后的回调函数
  - str：截图保存后的文件路径，如果截图失败则返回空字符串

#### getElementShotImage
```ts
function getElementShotImage(ele: UniElement|null, callback: (str: string) => void): void
```

**参数说明：**
- ele：要截图的目标元素，UniElement类型
- callback：截图完成后的回调函数
  - str：截图保存后的文件路径，如果截图失败则返回空字符串


### 示例代码 

```vue
<template>
  <x-sheet id="screentIds">
    <x-button class="mb-16" :block="true" @click="getScreenimg">保存屏幕图片</x-button>
    <x-button :block="true" @click="getSEleimg">保存节点截图</x-button>
  </x-sheet>
</template>

<script setup lang="ts">
import {getRootShotImage, getElementShotImage} from "@/uni_modules/x-screenshot-s"

const getScreenimg = () => {
  getRootShotImage((str: string) => {
    if(str == null) return;
    console.log(str)
    uni.previewImage({
      current: str,
      urls: [str] as string[]
    })
  })
}

const getSEleimg = () => {
  let ele = uni.getElementById("screentIds") as UniElement|null
  getElementShotImage(ele, (str: string) => {
    if(str == null) return;
    console.log(str)
    uni.previewImage({
      current: str,
      urls: [str] as string[]
    })
  })
}
</script>
```

### 常见问题

1. 截图黑屏或无内容
   - 确保已正确打包基座
   - 检查目标View是否已完成渲染
   - Android端确保View的宽高不为0

2. 截图文件路径无效
   - 检查应用是否有存储权限
   - 确保缓存目录可写入

3. 性能注意事项
   - 大尺寸View截图可能占用较多内存
   - 建议在截图后及时释放不需要的图片资源