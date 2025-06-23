# x-svg-u

### 开发文档

1. 使用时请注意，width,height一定要填写，且是px单位。并且style上也要写样式的宽和高。如果不写style安卓上不会显示
2. 不支持远程显示。如果要远程，你可以自己通过uni.download下载到本地显示。

```vue
<x-svg-u src="/static/undraw_farming_ni77.svg" :width="100" :height="120" :style="{width:'100px',height:'120px'}"></x-svg-u>
```

### 兼容性

| IOS	| IPAD	| macOs | Andriod	| WEB	|
| ---	| ---	| ---	| ---	| --- |
| 11+	| 11+	| -  	| 5.0+  | 支持 |

### 注意事项

使用前一定要打基座才可用，一定要在页面上先引用，再去打基座。
如果你mac开发。ios可以不用打基座，能直接使用（但前提是你要配置好原生开发环境，否则一样要打包）
如果你是开始安卓，不管是mac,win电脑都要打包基座才能使用。