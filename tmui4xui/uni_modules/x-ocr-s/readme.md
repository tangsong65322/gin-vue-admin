# x-ocr-s
### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

**如果需要查看效果请[下载TMUI4.0组件库应用demo](https://ext.dcloud.net.cn/plugin?id=16369)，导航到原生插件栏目体验。**

**本插件会让你的安卓应用增加大约8.7mb体积**
**本插件会让你的IOS应用增加大约38mb（估算）体积**
**web端需要网络加载模型文件，因为web无法离线，也不是调用api就是本地模型加载一次后，就不需要网络了**

### UniApp 适配的版本
[oc离线识别uniapp版本](https://ext.dcloud.net.cn/plugin?name=tm-ocr)

### 功能

支持以下特殊的ocr文本识别。**离线识别，不需要联网**

- 支持中文
- 支持英文
- 支持韩文
- 支持日文

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | x |

### 说明
这是tmui4.0|XUI的原生插件附赠插件。种子用户可免于购买。

非种子用户：

普通授权：99元
源码授权：299元

### 使用

如果是安卓请务必打自定义基座，如果ios：你在mac环境下配置好了环境无需打包本地编译，如果win开发ios需要打包基座。

安卓：

如果你需要32位系统和模拟器x86上运行，需要自行配置打包cpu 支持类型，配置abis
需要自定义基座运行，且安卓5.0+（含5.0）以上支持

Ios:
同样按照官方文档配置所需CPU类型，默认是arm64

WEB:
请复制插件目录中的static目录到低的根目录static目录中即可。

### API说明

插件提供了三个主要的API函数用于OCR文本识别：

#### 1. chooseImageBuilder
从相册或相机选择图片进行文字识别

```ts
chooseImageBuilder(
  callback: (str: string[], source: string[]) => void,
  langs: string|null
)
```

参数说明：
- callback：识别结果回调函数
  - str: 识别出的文本数组
  - source: 包含文本位置信息的数组，每个元素为JSON字符串，格式为：{boundingBox:[left,top,width,height], text:string}
- langs：识别语言，可选值：
  - 'zh'：中文识别
  - 'ja'：日文识别
  - null：默认中文zh

#### 2. downloadUrlImageBuilder
下载网络图片进行文字识别

```ts
downloadUrlImageBuilder(
  url: string,
  callback: (str: string[], source: string[]) => void,
  langs: string|null
)
```

参数说明：
- url：网络图片地址
- callback：识别结果回调函数，参数同chooseImageBuilder
- langs：识别语言，可选值同chooseImageBuilder

#### 3. localFilePathImageBuilder
识别本地图片文件

```ts
localFilePathImageBuilder(
  pathfile: string,
  callback: (str: string[], source: string[]) => void,
  langs: string|null
)
```

参数说明：
- pathfile：本地图片文件路径
- callback：识别结果回调函数，参数同chooseImageBuilder
- langs：识别语言，可选值同chooseImageBuilder

### 使用示例

```ts
import {chooseImageBuilder,downloadUrlImageBuilder,localFilePathImageBuilder} from "@/uni_modules/x-ocr-s"

// 从相册/相机选择图片识别
chooseImageBuilder((txt:string[], sour:string[])=>{
    // txt为识别出的文本数组
    // sour为包含位置信息的JSON字符串数组，需要JSON.parse转换
    sour.forEach(item => {
        const info = JSON.parse(item)
        console.log('文本:', info.text)
        console.log('位置:', info.boundingBox)
    })
}, 'zh')

// 识别网络图片
downloadUrlImageBuilder(
    'https://example.com/test.jpg',
    (txt:string[], sour:string[])=>{
        console.log('识别文本:', txt)
        console.log('详细信息:', sour)
    },
    'ja' // 日文识别
)

// 识别本地图片
localFilePathImageBuilder(
    '/static/test.png',
    (txt:string[], sour:string[])=>{
        console.log('识别文本:', txt)
        console.log('详细信息:', sour)
    },
    'zh' // 中文识别
)
```

### 注意事项

1. 识别置信度默认设置为0.50，只返回置信度大于等于0.50的识别结果
2. 回调函数中的source参数需要通过JSON.parse解析才能获取位置信息
3. 建议图片清晰度较高，避免模糊、反光等影响识别效果
4. Web端首次使用需要下载模型文件，请确保网络环境良好