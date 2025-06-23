# x-animation-s
### 开发文档
[TMUI4.0文档](https://xui.tmui.design/)
[TMUI4.0组件库](https://ext.dcloud.net.cn/plugin?id=16369)

### 功能特色

这是原生动画,性能好,有3d旋转效果,给你的应用增彩。基于原生实现，非CSS样式动画，具有高性能和流畅的动画效果。

### 兼容性

| IOS | Android | WEB | 小程序 |
| --- | --- | --- | --- |
| 支持 | 支持 | 支持 | 支持 |

### 说明
这是tmui4.0|XUI的原生插件附赠插件。种子用户可免于购买。

### 使用前提

需要自定义基座运行，且安卓5.0+（含5.0）以上支持。

### API接口说明

#### 1. translate - 位移动画
```typescript
interface XDANIMATION_TRANSLATE_OPTIONS {
    ele: UniElement|null;        // 目标元素
    duration?: number;           // 动画持续时间，默认1000ms
    delay?: number;             // 延迟执行时间，默认0ms
    translation?: number;        // 位移方向，默认0
    from?: number;              // 起始位置，默认360
    len?: number;               // 位移距离，默认360
    loop?: number;              // 循环次数，默认0
    start?: Function;           // 动画开始回调
    end?: Function;             // 动画结束回调
}
```

#### 2. rotate - 旋转动画
```typescript
interface XDANIMATION_ROTATE_OPTIONS {
    ele: UniElement|null;        // 目标元素
    duration?: number;           // 动画持续时间，默认1000ms
    delay?: number;             // 延迟执行时间，默认0ms
    from?: number;              // 起始角度，默认0
    deg?: number;               // 旋转角度，默认360
    loop?: number;              // 循环次数，默认0
    start?: Function;           // 动画开始回调
    end?: Function;             // 动画结束回调
}
```

#### 3. scale - 缩放动画
```typescript
interface XDANIMATION_SCALE_OPTIONS {
    ele: UniElement|null;        // 目标元素
    duration?: number;           // 动画持续时间，默认1000ms
    delay?: number;             // 延迟执行时间，默认0ms
    direction?: number;         // 缩放方向，默认2
    scale?: number;             // 目标缩放比例，默认1
    from?: number;              // 起始缩放比例，默认0
    loop?: number;              // 循环次数，默认0
    start?: Function;           // 动画开始回调
    end?: Function;             // 动画结束回调
}
```

#### 4. flip3D - 3D翻转动画
```typescript
interface XDANIMATION_FLIP3D_OPTIONS {
    ele: UniElement|null;        // 目标元素
    duration?: number;           // 动画持续时间，默认1000ms
    delay?: number;             // 延迟执行时间，默认0ms
    axis?: number;              // 翻转轴，默认1
    from?: number;              // 起始角度，默认0
    deg?: number;               // 翻转角度，默认360
    loop?: number;              // 循环次数，默认0
    cameraDistance?: number;    // 摄像机距离，默认12
    scaleZ?: number;            // Z轴缩放，默认0.5
    start?: Function;           // 动画开始回调
    end?: Function;             // 动画结束回调
}
```

### 特别注意事项

1. **iOS平台3D翻转限制**：
   - iOS平台下，3D翻转角度只能在0-180度之间
   - 如需实现360度翻转，需要分段执行：
     1. 先执行0-180度翻转
     2. 在回调中执行180-0度翻转

2. **生命周期回调**：
   - start：动画开始时触发
   - end：动画结束时触发
   - 可以在回调中执行连续动画或其他操作

### 使用示例

```vue
<template>
  <x-sheet id="xta">
    <view>动画目标元素</view>
  </x-sheet>
</template>

<script setup>
import { xAnimationS } from '@/uni_modules/x-animation-s';

// iOS平台360度翻转示例
const flip360 = () => {
  // #ifdef APP-IOS
  xAnimationS.flip3D({
    ele: uni.getElementById("xta"),
    deg: 180,
    from: 0,
    duration: 500,
    end: () => {
      xAnimationS.flip3D({
        ele: uni.getElementById("xta"),
        deg: 0,
        from: 180,
        duration: 500
      })
    }
  })
  // #endif
  // #ifndef APP-IOS
  xAnimationS.flip3D({
    ele: uni.getElementById("xta"),
    deg: 360,
    from: 0,
    duration: 1000
  })
  // #endif
}

// 缩放示例
const scaleAnimation = () => {
  xAnimationS.scale({
    ele: uni.getElementById("xta"),
    duration: 320,
    direction: 2,
    from: 0.6,
    scale: 1
  })
}

// 位移示例
const translateAnimation = () => {
  xAnimationS.translate({
    ele: uni.getElementById("xta"),
    duration: 320,
    translation: 0,
    from: 0,
    len: -100
  })
}

// 旋转示例
const rotateAnimation = () => {
  xAnimationS.rotate({
    ele: uni.getElementById("xta"),
    duration: 1000,
    from: 0,
    deg: 360
  })
}
</script>
```

### 动画组合示例

```javascript
// 连续动画示例：缩放-旋转-位移
const complexAnimation = () => {
  xAnimationS.scale({
    ele: uni.getElementById("xta"),
    duration: 500,
    from: 1,
    scale: 1.2,
    end: () => {
      xAnimationS.rotate({
        ele: uni.getElementById("xta"),
        duration: 500,
        deg: 180,
        end: () => {
          xAnimationS.translate({
            ele: uni.getElementById("xta"),
            duration: 500,
            len: 100
          })
        }
      })
    }
  })
}
```