# x-facedetection

## 特性说明

1. 检测提供的图片是否有人脸信息
2. 从相册中选取检测人脸信息
3. 通过相机实时捕捉人脸信息(并通过姿势姿态检测当前活体)
4. ios端后续提供,仅支持图片人脸信息检测

## 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| x | 支持 | x | x |

## 安装方式

通过HBuilderX导入插件，或在插件市场下载后导入项目。

## API接口说明

### 检测图片中的人脸

```ts
// 通过相册选择图片检测人脸
checkFaceByImage(config: XFACE_CHECK_OPTS)

// 通过提供的图片路径检测人脸
checkFaceByImageFromFilePath(config: XFACE_CHECK_OPTS)
```

### 通过相机进行人脸活体检测

```ts
// 检查相机权限
checkCamraPermissions(call: (istrue: boolean) => void)

// 打开相机进行人脸活体检测
checkFaceByCamra(config: XFACE_CHECK_OPTS)
```

## 参数类型说明

### XFACE_CHECK_OPTS

```ts
type XFACE_CHECK_OPTS = {
  // 如果是通过图片检测需要提供图片路径
  url?: string,
  // 如果是通过图片buffer解析需要提供(暂无法使用)
  buffer?: ArrayBuffer,
  // 如果是通过相机动态绑定嵌入式页面时,需要提供页面view的id
  viewId?: string,
  /**
   * 活体检测指令，通过相机视频检测
   * 如果提供指令数组时,会根据完整指令顺序检测直到验证通过.
   * 如果视频检测时,指令为空数组则只检测整个五官是不是在画面中,一旦检测到人脸立即验证通过.
   */
  instruction?: XFACE_INS[]
  // 验证结束并通过时返回
  success?: (data: XFACE_EVENT_CHECK_SUCCESS) => void,
  /**
   * 在视频活体检测时，返回每一帧的检测详细检测过程的信息，此事件是持续触发，直到结束。
   * 在图片检测的时候，只返回一次。
   */
  enter?: (data: XFACE_EVENT_SUCCESS[], maps: string) => void,
  /**
   * 开始检测，正在开始检测的指令。类似：向左转一次，向右转一次，点点头，张张嘴等执行时触发，
   * 方便用户自定自己的提示语或者语音播报
   * 'start'，现在开始，
   * 'ins_start_指令名称'：某个指令开始，如：ins_start_left,ins_start_right
   * 'ins_end_指令名称'：某个指令结束，如：ins_end_left,ins_end_right
   * 'end'结束所有指令
   */
  insTipsEvent?: (data: string) => void,
  fail?: (error: string) => void,
}
```

### 活体检测指令类型

```ts
/**
 * 活体检测指令，可以通过指令控制检测动作
 * left: 向左转一次
 * right: 向右转一次
 * downUp: 上下点头
 * eyeOplenClose: 眨眼
 * monthOpenClose: 张张嘴
 */
type XFACE_INS = "left" | "right" | "downUp" | "eyeOplenClose" | "monthOpenClose"
```

### 检测结果类型

```ts
type XFACE_EVENT_SUCCESS = {
  // 右眼眨眼睛的闭合数据
  rightEye: XFACE_TEST_EYE_TYPE,
  // 左眼眨眼睛的闭合数据
  leftEye: XFACE_TEST_EYE_TYPE,
  // 是否在微笑
  isSmile: boolean,
  // 脸向左,向右,中间
  faceRightLeft: XFACE_FACE_Direction,
  // 点头的方向
  faceUpDown: XFACE_FACE_Direction,
  imgWidth: number,
  imgHeight: number,
  // 嘴巴是不是张开
  isMouthOpened: boolean,
  // 整个脑袋是否在画面中
  allHeadBody: boolean,
  // 人脸ID，用于追踪同一个人脸
  faceId: number | null
}

type XFACE_EVENT_CHECK_SUCCESS = {
  /**
   * 验证结束保存的视频地址，方便上传保存到后台储存备份，抽查验证。
   * 仅在活体检测时返回，图片检测时为空字符串。
   */
  videoPath: string
  /**
   * 在活体检测过程中,会按照指令顺序进行截图,保存验证时人脸对应的动画图片。
   * 多少个指令就有多少张图片。最后一张为全脸捕捉画面。
   * 图片检测时，返回检测的图片路径。
   */
  images: string[],
  /**
   * 验证是否通过
   */
  isPass: boolean
}
```

## 使用示例

### 图片人脸检测

```ts
import { checkFaceByImage, checkFaceByImageFromFilePath } from '@/uni_modules/x-facedetection'

// 从相册选择图片检测人脸
checkFaceByImage({
  success: (res) => {
    console.log('检测成功', res.isPass)
    console.log('图片路径', res.images)
  },
  fail: (err) => {
    console.error('检测失败', err)
  },
  enter: (data, maps) => {
    console.log('人脸信息', data)
  }
})

// 通过图片路径检测人脸
checkFaceByImageFromFilePath({
  url: '图片路径',
  success: (res) => {
    console.log('检测成功', res.isPass)
    console.log('图片路径', res.images)
  },
  fail: (err) => {
    console.error('检测失败', err)
  },
  enter: (data, maps) => {
    console.log('人脸信息', data)
  }
})
```

### 相机活体检测

```ts
import { checkCamraPermissions, checkFaceByCamra } from '@/uni_modules/x-facedetection/utssdk/app-android/index.uts'

// 检查相机权限
checkCamraPermissions((hasPermission) => {
  if (hasPermission) {
    // 有权限，开始活体检测
    startFaceDetection()
  } else {
    console.error('没有相机权限')
  }
})

// 开始活体检测
function startFaceDetection() {
  checkFaceByCamra({
    viewId: 'camera-container', // 相机预览容器的ID
    instruction: ['left', 'right', 'eyeOplenClose', 'monthOpenClose'], // 活体检测指令序列
    insTipsEvent: (event) => {
      // 处理指令提示事件
      if (event === 'start') {
        console.log('开始检测')
      } else if (event.startsWith('ins_start_')) {
        const action = event.replace('ins_start_', '')
        console.log(`开始执行动作: ${action}`)
      } else if (event.startsWith('ins_end_')) {
        const action = event.replace('ins_end_', '')
        console.log(`完成动作: ${action}`)
      } else if (event === 'end') {
        console.log('检测完成')
      }
    },
    success: (res) => {
      console.log('活体检测成功', res.isPass)
      console.log('视频路径', res.videoPath)
      console.log('检测过程图片', res.images)
    },
    fail: (err) => {
      console.error('活体检测失败', err)
    },
    enter: (data, maps) => {
      // 实时人脸检测数据
      console.log('实时人脸数据', data)
    }
  })
}
```

## 注意事项

1. 活体检测需要用户保持面部在摄像头范围内，并按照指令完成相应动作
2. 检测过程中如果用户移出屏幕或光线变化太大，可能会导致检测失败
3. 为获得最佳效果，建议在光线充足的环境下使用
4. iOS和Android实现可能存在细微差异，请根据实际测试结果调整应用逻辑
